import 'dart:async';
import 'dart:io';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/owner_profile/presentation/view/owner_profile_page.dart';
import 'package:aqar_hub/features/shared/chat/data/models/conversation_model.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'chat/chat_app_bar.dart';
import 'chat/chat_bubbles.dart';
import 'chat/chat_input_bar.dart';
import 'chat/chat_misc_widgets.dart';
import 'chat/chat_voice_bar.dart';

export 'package:aqar_hub/features/shared/chat/data/models/chat_message_model.dart'
    show PropertyCardMeta;

class ChatConversationView extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final PropertyCardMeta? initialPropertyCard;

  const ChatConversationView({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.initialPropertyCard,
  });

  @override
  State<ChatConversationView> createState() => _State();
}

class _State extends State<ChatConversationView> {
  final _repo = ChatRepositoryImpl(ChatRemoteDatasource());
  final _streamCtrl = StreamController<List<ChatMessageModel>>.broadcast();

  List<ChatMessageModel> _messages = [];
  bool _hasMore = false,
      _loadingMore = false,
      _initialLoad = true,
      _sending = false;
  final Map<String, String> _pendingVideos = {};

  PropertyCardMeta? _contextCard;
  bool _contextExpanded = true;
  PresenceModel? _otherPresence;

  RealtimeChannel? _msgCh, _presCh;
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  Timer? _typingTimer;

  // Voice recording
  final _recorder = AudioRecorder();
  bool _isRecording = false, _recordCancelled = false;
  DateTime? _recordStart;
  Timer? _recordTimer;
  int _recordSecs = 0;
  double _dragOffset = 0.0;

  static const _pageSize = 30;
  String get _myId => _repo.currentUserId;

  @override
  void initState() {
    super.initState();
    _contextCard = widget.initialPropertyCard;
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _stopTyping();
    _repo.goOffline();
    if (_msgCh != null) _repo.unsubscribe(_msgCh!);
    if (_presCh != null) _repo.unsubscribe(_presCh!);
    _streamCtrl.close();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() => _initialLoad = true);
    try {
      final msgs = await _repo.getMessages(
        conversationId: widget.conversationId,
      );
      final pres = await _repo.getPresence(widget.otherUserId);
      if (!mounted) return;
      _messages = msgs;
      _hasMore = msgs.length >= _pageSize;
      if (_contextCard == null && msgs.isNotEmpty) {
        _contextCard = PropertyCardMeta.tryParseContent(msgs.first.content);
      }
      setState(() {
        _otherPresence = pres;
        _initialLoad = false;
      });
      _push();
      _repo.markAsRead(widget.conversationId).then((_) {
        if (!mounted) return;
        setState(
          () => _messages = _messages
              .map(
                (m) => m.senderId != _myId && !m.isRead
                    ? m.copyWith(isRead: true)
                    : m,
              )
              .toList(),
        );
        _push();
      });
      unawaited(_repo.goOnline());
      _subscribePresence();

      // FIX: Send the initial property card BEFORE subscribing to realtime messages.
      // Previously, the subscription was live while the send + push awaited, so the
      // realtime INSERT event arrived and added the message, then the code below also
      // added it — creating a duplicate. By starting the subscription AFTER we have
      // manually added the sent message, the dedup check always catches any late
      // realtime echo.
      if (_messages.isEmpty && widget.initialPropertyCard != null) {
        final sent = await _repo.sendText(
          conversationId: widget.conversationId,
          text: widget.initialPropertyCard!.toContentString(),
        );
        await _sendPush('🏠 ${widget.initialPropertyCard!.title}');
        if (mounted) {
          _messages = [..._messages, sent];
          _push();
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(animated: true),
          );
        }
      }

      // Subscribe only now — _messages already contains the initial card (if any),
      // so the dedup guard in onMessage will prevent any duplicate.
      _subscribeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  void _push() {
    if (!_streamCtrl.isClosed) _streamCtrl.add(List.unmodifiable(_messages));
  }

  // ── Push notification helper ───────────────────────────────────────────────

  Future<void> _sendPush(String body) async {
    try {
      await FcmService.instance.sendPushToUser(
        recipientUid: widget.otherUserId,
        title: widget.otherUserName.isNotEmpty
            ? widget.otherUserName
            : 'رسالة جديدة',
        body: body.length > 100 ? '${body.substring(0, 100)}...' : body,
        type: 'new_message',
        data: {'conversation_id': widget.conversationId},
      );
    } catch (e) {
      debugPrint('[Chat] _sendPush error: $e');
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  void _onScroll() {
    if (_scrollCtrl.position.pixels <= 120 && _hasMore && !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _messages.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final older = await _repo.getMessages(
        conversationId: widget.conversationId,
        before: _messages.first.createdAt,
      );
      _messages = [...older, ..._messages];
      _hasMore = older.length >= _pageSize;
      _push();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeMessages() {
    _msgCh = _repo.subscribeMessages(
      conversationId: widget.conversationId,
      onReadUpdate: () {
        if (!mounted) return;
        setState(
          () => _messages = _messages
              .map(
                (m) => m.senderId == _myId && !m.isRead
                    ? m.copyWith(isRead: true)
                    : m,
              )
              .toList(),
        );
        _push();
      },
      onMessage: (msg) {
        if (!mounted) return;
        if (_messages.any((m) => m.id == msg.id)) return;
        _messages = [..._messages, msg];
        _push();
        if (_contextCard == null && msg.isPropertyCard) {
          setState(() {
            _contextCard = msg.propertyCard;
            _contextExpanded = true;
          });
        }
        if (msg.senderId != _myId) {
          _repo.markAsRead(widget.conversationId).then((_) {
            if (!mounted) return;
            setState(
              () => _messages = _messages
                  .map(
                    (m) => m.senderId != _myId && !m.isRead
                        ? m.copyWith(isRead: true)
                        : m,
                  )
                  .toList(),
            );
            _push();
          });
        }
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      },
    );
  }

  void _subscribePresence() {
    _presCh = _repo.subscribePresence(
      userId: widget.otherUserId,
      onUpdate: (row) {
        if (mounted) {
          setState(() => _otherPresence = PresenceModel.fromMap(row));
        }
      },
    );
  }

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    animated
        ? _scrollCtrl.animateTo(
            max,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          )
        : _scrollCtrl.jumpTo(max);
  }

  // ── Send text ─────────────────────────────────────────────────────────────

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _textCtrl.clear();
    _stopTyping();
    setState(() => _sending = true);
    try {
      final sent = await _repo.sendText(
        conversationId: widget.conversationId,
        text: text,
      );
      // Push notification to recipient — awaited so errors are logged
      await _sendPush(text);
      if (mounted && !_messages.any((m) => m.id == sent.id)) {
        _messages = [..._messages, sent];
        _push();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Send property card ────────────────────────────────────────────────────

  Future<void> _sendPropertyCard() async {
    final card = _contextCard;
    if (card == null || _sending) return;
    setState(() => _sending = true);
    try {
      final sent = await _repo.sendText(
        conversationId: widget.conversationId,
        text: card.toContentString(),
      );
      await _sendPush('🏠 ${card.title}');
      if (mounted && !_messages.any((m) => m.id == sent.id)) {
        _messages = [..._messages, sent];
        _push();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Pick & send images ────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty || !mounted) return;
    final picked = files.map((f) => File(f.path)).toList();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ImagePreviewSheet(
        images: picked,
        onSend: (_) => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        onAddMore: null,
      ),
    );
    if (confirmed == true) await _sendImages(picked);
  }

  Future<void> _sendImages(List<File> images) async {
    setState(() => _sending = true);
    try {
      for (final img in images) {
        final sent = await _repo.sendMedia(
          conversationId: widget.conversationId,
          file: img,
          type: MessageType.image,
        );
        if (mounted && !_messages.any((m) => m.id == sent.id)) {
          _messages = [..._messages, sent];
          _push();
        }
      }
      // Single notification for all images sent together
      await _sendPush('📷 صورة');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Pick & send video ─────────────────────────────────────────────────────

  Future<void> _pickVideo() async {
    final f = await _picker.pickVideo(source: ImageSource.gallery);
    if (f == null || !mounted) return;
    final tempId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessageModel(
      id: tempId,
      conversationId: widget.conversationId,
      senderId: _myId,
      type: MessageType.video,
      mediaUrl: null,
      isRead: false,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages = [..._messages, tempMsg];
      _pendingVideos[tempId] = f.path;
    });
    _push();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: true),
    );
    try {
      final sent = await _repo.sendMedia(
        conversationId: widget.conversationId,
        file: File(f.path),
        type: MessageType.video,
      );
      await _sendPush('🎥 فيديو');
      if (mounted) {
        setState(() {
          _messages = [..._messages.where((m) => m.id != tempId), sent];
          _pendingVideos.remove(tempId);
        });
        _push();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != tempId).toList();
          _pendingVideos.remove(tempId);
        });
        _push();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('chat_video_upload_failed'.tr(context)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Voice recording & send ────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    setState(() {
      _isRecording = true;
      _recordCancelled = false;
      _recordStart = DateTime.now();
      _recordSecs = 0;
      _dragOffset = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isRecording) setState(() => _recordSecs++);
    });
  }

  Future<void> _stopAndSend() async {
    _recordTimer?.cancel();
    if (!_isRecording) return;
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordSecs = 0;
      _dragOffset = 0;
    });
    if (_recordCancelled || path == null) return;
    final dur = _recordStart != null
        ? DateTime.now().difference(_recordStart!).inSeconds
        : 0;
    if (dur < 1) return;
    setState(() => _sending = true);
    try {
      final sent = await _repo.sendMedia(
        conversationId: widget.conversationId,
        file: File(path),
        type: MessageType.voice,
        durationSecs: dur,
      );
      await _sendPush('🎤 رسالة صوتية');
      if (mounted && !_messages.any((m) => m.id == sent.id)) {
        _messages = [..._messages, sent];
        _push();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: true),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _recordCancelled = true;
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordSecs = 0;
      _dragOffset = 0;
    });
  }

  // ── Typing ────────────────────────────────────────────────────────────────

  void _onTextChanged(String _) {
    _typingTimer?.cancel();
    _repo.setTyping(conversationId: widget.conversationId, isTyping: true);
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    _repo.setTyping(conversationId: widget.conversationId, isTyping: false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final typing = _otherPresence?.isTypingIn(widget.conversationId) ?? false;
    final online = _otherPresence?.isOnlineNow ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1B2D5E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: ChatAppBar(
          otherUserName: widget.otherUserName,
          otherUserAvatar: widget.otherUserAvatar,
          isOnline: online,
          isTyping: typing,
          lastSeenAt: _otherPresence?.lastSeenAt,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OwnerProfilePage(
                ownerId: widget.otherUserId,
                ownerName: widget.otherUserName,
                ownerAvatar: widget.otherUserAvatar,
              ),
            ),
          ),
          onBack: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            if (_contextCard != null)
              PropertyContextStrip(
                card: _contextCard!,
                expanded: _contextExpanded,
                onToggle: () =>
                    setState(() => _contextExpanded = !_contextExpanded),
              ),
            Expanded(
              child: _initialLoad
                  ? const MessagesSkeleton()
                  : StreamBuilder<List<ChatMessageModel>>(
                      stream: _streamCtrl.stream,
                      initialData: _messages,
                      builder: (_, snap) {
                        final msgs = snap.data ?? [];
                        if (msgs.isEmpty) {
                          return EmptyChat(
                            name: widget.otherUserName,
                            card: _contextCard,
                          );
                        }
                        return _MsgList(
                          messages: msgs,
                          myId: _myId,
                          hasMore: _hasMore,
                          loadingMore: _loadingMore,
                          scrollController: _scrollCtrl,
                        );
                      },
                    ),
            ),
            if (typing) TypingIndicator(name: widget.otherUserName),
            _isRecording
                ? ChatVoiceBar(
                    secs: _recordSecs,
                    dragOffset: _dragOffset,
                    onDragUpdate: (dx) {
                      setState(() => _dragOffset = dx);
                      if (dx < -80) _cancelRecording();
                    },
                    onRelease: _stopAndSend,
                    onCancel: _cancelRecording,
                  )
                : ChatInputBar(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    sending: _sending,
                    hasPropertyCard: _contextCard != null,
                    onChanged: _onTextChanged,
                    onSendText: _sendText,
                    onPickImage: _pickImage,
                    onPickVideo: _pickVideo,
                    onShareCard: _sendPropertyCard,
                    onStartRecord: _startRecording,
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Messages list ─────────────────────────────────────────────────────────────

class _MsgList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final String myId;
  final bool hasMore, loadingMore;
  final ScrollController scrollController;

  const _MsgList({
    required this.messages,
    required this.myId,
    required this.hasMore,
    required this.loadingMore,
    required this.scrollController,
  });

  bool _sameDay(DateTime a, DateTime b) =>
      a.toLocal().year == b.toLocal().year &&
      a.toLocal().month == b.toLocal().month &&
      a.toLocal().day == b.toLocal().day;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: context.rOnly(left: 10, right: 10, top: 12, bottom: 20),
      itemCount: messages.length + (hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == 0 && hasMore) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.r(8)),
            child: Center(
              child: loadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }
        final idx = hasMore ? i - 1 : i;
        final msg = messages[idx];
        Widget? divider;
        if (idx == 0 || !_sameDay(messages[idx - 1].createdAt, msg.createdAt)) {
          divider = DateDivider(date: msg.createdAt);
        }
        return Column(
          children: [
            if (divider != null) divider,
            MessageBubble(message: msg, isMine: msg.senderId == myId),
          ],
        );
      },
    );
  }
}
