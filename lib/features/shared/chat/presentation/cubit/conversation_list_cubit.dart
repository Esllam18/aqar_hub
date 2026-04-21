import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository_impl.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class ConversationListState {
  const ConversationListState();
}

final class ConversationListInitial extends ConversationListState {
  const ConversationListInitial();
}

final class ConversationListLoading extends ConversationListState {
  const ConversationListLoading();
}

final class ConversationListLoaded extends ConversationListState {
  final List<ConversationModel> conversations;
  const ConversationListLoaded(this.conversations);
}

final class ConversationListError extends ConversationListState {
  final String message;
  const ConversationListError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ConversationListCubit extends Cubit<ConversationListState> {
  final ChatRepositoryImpl _repo;
  RealtimeChannel? _channel;
  RealtimeChannel? _msgChannel;

  ConversationListCubit(this._repo) : super(const ConversationListInitial());

  String? get myIdOrNull => _repo.currentUserIdOrNull;

  String get myId => _repo.currentUserId;

  Future<void> load() async {
    final cached = AppPrefs.getCachedConversations();
    if (cached != null && cached.isNotEmpty) {
      try {
        final models = cached.map(ConversationModel.fromMap).toList();
        if (!isClosed) emit(ConversationListLoaded(models));
        _connectAndRefresh();
        return;
      } catch (_) {}
    }
    emit(const ConversationListLoading());
    _connectAndRefresh();
  }

  Future<void> _connectAndRefresh() async {
    try {
      await _repo.goOnline();
      final list = await _repo.getConversations();
      _writeCache(list);
      if (!isClosed) emit(ConversationListLoaded(list));
      _subscribeRealtime(list);
    } catch (e) {
      if (state is! ConversationListLoaded) {
        if (!isClosed) emit(ConversationListError(e.toString()));
      }
    }
  }

  void _subscribeRealtime(List<ConversationModel> conversations) {
    _channel?.unsubscribe();
    _msgChannel?.unsubscribe();

    _channel = _repo.subscribeConversations(
      onUpdate: (row) async {
        try {
          final list = await _repo.getConversations();
          _writeCache(list);
          if (!isClosed) {
            emit(ConversationListLoaded(list));
            // Re-subscribe with updated conversation IDs
            _resubscribeMessages(list);
          }
        } catch (_) {}
      },
    );

    _resubscribeMessages(conversations);
  }

  void _resubscribeMessages(List<ConversationModel> conversations) {
    _msgChannel?.unsubscribe();
    final ids = conversations.map((c) => c.id).toList();
    _msgChannel = _repo.subscribeAllMessages(
      conversationIds: ids,
      onInsert: (_) async {
        try {
          final list = await _repo.getConversations();
          _writeCache(list);
          if (!isClosed) emit(ConversationListLoaded(list));
        } catch (_) {}
      },
    );
  }

  void _writeCache(List<ConversationModel> list) {
    try {
      AppPrefs.cacheConversations(list.map((c) => c.toMap()).toList());
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    if (_channel != null) _repo.unsubscribe(_channel!);
    if (_msgChannel != null) _repo.unsubscribe(_msgChannel!);

    super.close();
  }
}