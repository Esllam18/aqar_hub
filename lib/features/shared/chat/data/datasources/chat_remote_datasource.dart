import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDatasource {
  SupabaseClient get _db => Supabase.instance.client;

  static const _bucket = 'chat_media';
  static const int _pageSize = 30;


  String? get currentUserIdOrNull => _db.auth.currentUser?.id;

  String get currentUserId {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    return uid;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONVERSATIONS
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> upsertConversation(String otherUserId) async {
    final result = await _db.rpc(
      'upsert_conversation',
      params: {'user_a': currentUserId, 'user_b': otherUserId},
    );
    return result as String;
  }


  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final myId = currentUserId;

    final rows = await _db
        .from('conversations')
        .select()
        .or('participant_a.eq.$myId,participant_b.eq.$myId')
        .order('updated_at', ascending: false);

    final convList = List<Map<String, dynamic>>.from(
      (rows as List).map((r) => Map<String, dynamic>.from(r as Map)),
    );

    // Collect all other-user IDs in one pass
    final otherIds = <String>{};
    for (final conv in convList) {
      final otherId = conv['participant_a'] == myId
          ? conv['participant_b'] as String
          : conv['participant_a'] as String;
      otherIds.add(otherId);
    }

    // ONE batch query for all profiles instead of N sequential calls
    final profiles = <String, Map<String, dynamic>>{};
    if (otherIds.isNotEmpty) {
      final pRows = await _db
          .from('profiles')
          .select('id, first_name, last_name, profile_image_url')
          .inFilter('id', otherIds.toList());
      for (final row in pRows as List) {
        final m = Map<String, dynamic>.from(row as Map);
        profiles[m['id'] as String] = m;
      }
    }

    // Build result using the profile map — O(1) lookup per conversation
    final result = <Map<String, dynamic>>[];
    for (final conv in convList) {
      final otherId = conv['participant_a'] == myId
          ? conv['participant_b'] as String
          : conv['participant_a'] as String;
      final profile = profiles[otherId];
      if (profile != null) {
        final first = (profile['first_name'] ?? '').toString();
        final last = (profile['last_name'] ?? '').toString();
        conv['other_user_name'] = '$first $last'.trim();
        conv['other_user_avatar'] = profile['profile_image_url'];
      }
      result.add(conv);
    }
    return result;
  }

  /// Reset unread counter for current user in [conversationId].
  Future<void> clearUnread(String conversationId) async {
    final myId = currentUserId;
    final conv = await _db
        .from('conversations')
        .select('participant_a')
        .eq('id', conversationId)
        .single();
    final isA = conv['participant_a'] == myId;
    await _db
        .from('conversations')
        .update(isA ? {'unread_a': 0} : {'unread_b': 0})
        .eq('id', conversationId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MESSAGES
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchMessages({
    required String conversationId,
    DateTime? before,
  }) async {
    var builder = _db
        .from('messages')
        .select()
        .eq('conversation_id', conversationId);

    if (before != null) {
      builder = builder.lt('created_at', before.toIso8601String());
    }

    final rows = await builder
        .order('created_at', ascending: false)
        .limit(_pageSize);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<ChatMessageModel> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    final row = await _db
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': currentUserId,
          'message_type': 'text',
          'content': text.trim(),
        })
        .select()
        .single();
    final message = ChatMessageModel.fromMap(row);
    await _touchConversation(
      conversationId: conversationId,
      lastMessage: text.trim(),
    );
    return message;
  }

  Future<void> _touchConversation({
    required String conversationId,
    required String lastMessage,
  }) async {
    try {
      final myId = currentUserId;
      final conv = await _db
          .from('conversations')
          .select('participant_a, unread_a, unread_b')
          .eq('id', conversationId)
          .single();
      final isA = conv['participant_a'] == myId;
      final unreadKey = isA ? 'unread_b' : 'unread_a';
      final currentUnread =
          ((isA ? conv['unread_b'] : conv['unread_a']) as int?) ?? 0;

      await _db.from('conversations').update({
        'last_message': lastMessage.length > 100
            ? '${lastMessage.substring(0, 100)}...'
            : lastMessage,
        'last_sender_id': myId,
        'last_message_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        unreadKey: currentUnread + 1,
      }).eq('id', conversationId);
    } catch (e) {
      debugPrint('[Chat] _touchConversation error: $e');
    }
  }

  Future<ChatMessageModel> sendMediaMessage({
    required String conversationId,
    required File file,
    required MessageType type,
    int? durationSecs,
  }) async {
    final uid = currentUserId;
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = '$uid/$conversationId/$name';

    final contentType = switch (type) {
      MessageType.image => 'image/$ext',
      MessageType.video => 'video/$ext',
      MessageType.voice => 'audio/$ext',
      _ => 'application/octet-stream',
    };

    await _db.storage.from(_bucket).upload(
          storagePath,
          file,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    final url = _db.storage.from(_bucket).getPublicUrl(storagePath);

    final payload = {
      'conversation_id': conversationId,
      'sender_id': uid,
      'message_type': type.name,
      'media_url': url,
      if (durationSecs != null) 'duration_secs': durationSecs,
    };

    final row = await _db.from('messages').insert(payload).select().single();
    final message = ChatMessageModel.fromMap(row);

    final label = type == MessageType.image ? '📷 Photo' : '🎤 Voice message';
    await _touchConversation(
      conversationId: conversationId,
      lastMessage: label,
    );
    return message;
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    final myId = currentUserId;
    await _db
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_id', myId);
    await clearUnread(conversationId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REALTIME SUBSCRIPTIONS
  // ─────────────────────────────────────────────────────────────────────────

  RealtimeChannel subscribeToMessages({
    required String conversationId,
    required void Function(ChatMessageModel) onMessage,
    void Function()? onReadUpdate,
  }) {
    final channel = _db.channel('messages:$conversationId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) =>
          onMessage(ChatMessageModel.fromMap(payload.newRecord)),
    );
    if (onReadUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          if (payload.newRecord['is_read'] == true) {
            onReadUpdate();
          }
        },
      );
    }
    channel.subscribe();
    return channel;
  }

  RealtimeChannel subscribeToConversations({
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    final myId = currentUserId;
    final channel = _db.channel('conversations:$myId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
    return channel;
  }

  /// Listens to new message INSERTs — filtered to conversations where
  /// the current user is a participant. Prevents listening to all DB traffic.
  RealtimeChannel subscribeToAllMessages({
    required void Function(Map<String, dynamic>) onInsert,
    required List<String> conversationIds,
  }) {
    final myId = currentUserId;
    final channel = _db.channel('my_messages:$myId');

    // Only subscribe if we have conversations to watch
    if (conversationIds.isEmpty) {
      channel.subscribe();
      return channel;
    }

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final convId = payload.newRecord['conversation_id'] as String?;
            if (convId != null && conversationIds.contains(convId)) {
              onInsert(payload.newRecord);
            }
          },
        )
        .subscribe();
    return channel;
  }

  RealtimeChannel subscribeToPresence({
    required String userId,
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    final channel = _db.channel('presence:$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'presence',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
    return channel;
  }

  void unsubscribe(RealtimeChannel channel) {
    _db.removeChannel(channel);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRESENCE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setOnline() async {
    await _db.from('presence').upsert({
      'user_id': currentUserId,
      'is_online': true,
      'last_seen_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> setOffline() async {
    try {
      final uid = currentUserIdOrNull;
      if (uid == null) return;
      await _db.from('presence').update({
        'is_online': false,
        'last_seen_at': DateTime.now().toIso8601String(),
        'typing_in': null,
      }).eq('user_id', uid);
    } catch (_) {}
  }

  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      await _db.from('presence').upsert({
        'user_id': currentUserId,
        'is_online': true,
        'typing_in': isTyping ? conversationId : null,
        'last_seen_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> fetchPresence(String userId) async {
    try {
      return await _db
          .from('presence')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }
}