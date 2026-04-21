import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatRepositoryImpl {
  final ChatRemoteDatasource _ds;
  ChatRepositoryImpl(this._ds);

  String? get currentUserIdOrNull => _ds.currentUserIdOrNull;

  String get currentUserId => _ds.currentUserId;

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<String> openConversation(String otherUserId) =>
      _ds.upsertConversation(otherUserId);

  Future<List<ConversationModel>> getConversations() async {
    final rows = await _ds.fetchConversations();
    return rows.map(ConversationModel.fromMap).toList();
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Future<List<ChatMessageModel>> getMessages({
    required String conversationId,
    DateTime? before,
  }) async {
    final rows = await _ds.fetchMessages(
      conversationId: conversationId,
      before: before,
    );
    final models = rows.map(ChatMessageModel.fromMap).toList();
    return models.reversed.toList();
  }

  Future<ChatMessageModel> sendText({
    required String conversationId,
    required String text,
  }) => _ds.sendTextMessage(conversationId: conversationId, text: text);

  Future<ChatMessageModel> sendMedia({
    required String conversationId,
    required File file,
    required MessageType type,
    int? durationSecs,
  }) => _ds.sendMediaMessage(
    conversationId: conversationId,
    file: file,
    type: type,
    durationSecs: durationSecs,
  );

  Future<void> markAsRead(String conversationId) =>
      _ds.markMessagesAsRead(conversationId);

  // ── Realtime ───────────────────────────────────────────────────────────────

  RealtimeChannel subscribeMessages({
    required String conversationId,
    required void Function(ChatMessageModel) onMessage,
    void Function()? onReadUpdate,
  }) => _ds.subscribeToMessages(
    conversationId: conversationId,
    onMessage: onMessage,
    onReadUpdate: onReadUpdate,
  );

  RealtimeChannel subscribeConversations({
    required void Function(Map<String, dynamic>) onUpdate,
  }) => _ds.subscribeToConversations(onUpdate: onUpdate);


  RealtimeChannel subscribeAllMessages({
    required void Function(Map<String, dynamic>) onInsert,
    required List<String> conversationIds,
  }) => _ds.subscribeToAllMessages(
    onInsert: onInsert,
    conversationIds: conversationIds,
  );

  RealtimeChannel subscribePresence({
    required String userId,
    required void Function(Map<String, dynamic>) onUpdate,
  }) => _ds.subscribeToPresence(userId: userId, onUpdate: onUpdate);

  void unsubscribe(RealtimeChannel channel) => _ds.unsubscribe(channel);

  // ── Presence ───────────────────────────────────────────────────────────────

  Future<void> goOnline() => _ds.setOnline();
  Future<void> goOffline() => _ds.setOffline();

  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  }) => _ds.setTyping(conversationId: conversationId, isTyping: isTyping);

  Future<PresenceModel?> getPresence(String userId) async {
    final map = await _ds.fetchPresence(userId);
    if (map == null) return null;
    return PresenceModel.fromMap(map);
  }
}