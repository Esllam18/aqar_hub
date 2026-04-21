// lib/features/shared/chat/presentation/cubit/chat_cubit.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository_impl.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool hasMore; // can load older pages
  final bool loadingMore; // loading older page
  final bool sending; // uploading / sending a message
  final PresenceModel? otherPresence;

  const ChatLoaded({
    required this.messages,
    this.hasMore = false,
    this.loadingMore = false,
    this.sending = false,
    this.otherPresence,
  });

  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? hasMore,
    bool? loadingMore,
    bool? sending,
    PresenceModel? otherPresence,
    bool clearPresence = false,
  }) => ChatLoaded(
    messages: messages ?? this.messages,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    sending: sending ?? this.sending,
    otherPresence: clearPresence ? null : (otherPresence ?? this.otherPresence),
  );
}

final class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ChatCubit extends Cubit<ChatState> {
  final ChatRepositoryImpl _repo;
  final String conversationId;
  final String otherUserId;

  RealtimeChannel? _msgChannel;
  RealtimeChannel? _presenceChannel;
  Timer? _typingTimer;
  static const int _pageSize = 30;

  ChatCubit({
    required ChatRepositoryImpl repo,
    required this.conversationId,
    required this.otherUserId,
  }) : _repo = repo,
       super(const ChatInitial());

  String get myId => _repo.currentUserId;

  // ── Initial load ────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const ChatLoading());
    try {
      final messages = await _repo.getMessages(conversationId: conversationId);
      final presence = await _repo.getPresence(otherUserId);

      if (!isClosed) {
        emit(
          ChatLoaded(
            messages: messages,
            hasMore: messages.length >= _pageSize,
            otherPresence: presence,
          ),
        );
      }

      await _repo.markAsRead(conversationId);
      _subscribeMessages();
      _subscribePresence();
    } catch (e, s) {
      debugPrint('ChatCubit.load error: $e\n$s');
      if (!isClosed) emit(ChatError(e.toString()));
    }
  }

  // ── Load older messages (pagination) ───────────────────────────────────────

  Future<void> loadMore() async {
    final current = state;
    if (current is! ChatLoaded || current.loadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(loadingMore: true));
    try {
      final oldest = current.messages.first.createdAt;
      final older = await _repo.getMessages(
        conversationId: conversationId,
        before: oldest,
      );
      if (!isClosed) {
        emit(
          current.copyWith(
            messages: [...older, ...current.messages],
            hasMore: older.length >= _pageSize,
            loadingMore: false,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) emit(current.copyWith(loadingMore: false));
    }
  }

  // ── Send text ───────────────────────────────────────────────────────────────

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    _stopTyping();
    try {
      await _repo.sendText(conversationId: conversationId, text: text);
      // Message arrives via realtime subscription — also push to recipient
      FcmService.instance.sendPushToUser(
        recipientUid: otherUserId,
        title: 'رسالة جديدة',
        body: text.length > 80 ? '${text.substring(0, 80)}...' : text,
        type: 'new_message',
        data: {'conversation_id': conversationId},
      );
    } catch (e) {
      debugPrint('ChatCubit.sendText error: $e');
    }
  }

  // ── Send media ──────────────────────────────────────────────────────────────

  Future<void> sendMedia({
    required File file,
    required MessageType type,
    int? durationSecs,
  }) async {
    final current = state;
    if (current is! ChatLoaded) return;

    emit(current.copyWith(sending: true));
    try {
      await _repo.sendMedia(
        conversationId: conversationId,
        file: file,
        type: type,
        durationSecs: durationSecs,
      );
      // Push to recipient for media messages too
      final label = type == MessageType.image ? '📷 صورة' : '🎤 رسالة صوتية';
      FcmService.instance.sendPushToUser(
        recipientUid: otherUserId,
        title: 'رسالة جديدة',
        body: label,
        type: 'new_message',
        data: {'conversation_id': conversationId},
      );
    } catch (e) {
      debugPrint('ChatCubit.sendMedia error: $e');
    } finally {
      if (!isClosed && state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(sending: false));
      }
    }
  }

  // ── Typing indicator ────────────────────────────────────────────────────────

  void onTyping() {
    _typingTimer?.cancel();
    _repo.setTyping(conversationId: conversationId, isTyping: true);
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    _repo.setTyping(conversationId: conversationId, isTyping: false);
  }

  // ── Realtime ────────────────────────────────────────────────────────────────

  void _subscribeMessages() {
    _msgChannel = _repo.subscribeMessages(
      conversationId: conversationId,
      onMessage: (msg) {
        if (isClosed) return;
        final current = state;
        if (current is ChatLoaded) {
          // Avoid duplicates
          final exists = current.messages.any((m) => m.id == msg.id);
          if (!exists) {
            emit(current.copyWith(messages: [...current.messages, msg]));
          }
          // Mark as read if message is from other user
          if (msg.senderId != myId) {
            _repo.markAsRead(conversationId);
          }
        }
      },
      onReadUpdate: () {
        if (isClosed) return;
        final current = state;
        if (current is ChatLoaded) {
          // Mark all our sent messages as read in local state
          final updated = current.messages
              .map(
                (m) => m.senderId == myId && !m.isRead
                    ? m.copyWith(isRead: true)
                    : m,
              )
              .toList();
          emit(current.copyWith(messages: updated));
        }
      },
    );
  }

  void _subscribePresence() {
    _presenceChannel = _repo.subscribePresence(
      userId: otherUserId,
      onUpdate: (row) {
        if (isClosed) return;
        final current = state;
        if (current is ChatLoaded) {
          emit(current.copyWith(otherPresence: PresenceModel.fromMap(row)));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    _typingTimer?.cancel();
    _stopTyping();
    if (_msgChannel != null) _repo.unsubscribe(_msgChannel!);
    if (_presenceChannel != null) _repo.unsubscribe(_presenceChannel!);
    super.close();
  }
}
