// lib/features/shared/chat/data/models/conversation_model.dart

class ConversationModel {
  final String id;
  final String participantA;
  final String participantB;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final int unreadA;
  final int unreadB;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined from profiles — populated by repository
  final String? otherUserName;
  final String? otherUserAvatar;

  const ConversationModel({
    required this.id,
    required this.participantA,
    required this.participantB,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    required this.unreadA,
    required this.unreadB,
    required this.createdAt,
    required this.updatedAt,
    this.otherUserName,
    this.otherUserAvatar,
  });

  /// Returns the ID of the other participant (not the current user).
  String otherUserId(String myId) =>
      participantA == myId ? participantB : participantA;

  /// Returns the unread count FOR the current user.
  int unreadFor(String myId) => participantA == myId ? unreadA : unreadB;

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: (map['id'] ?? '').toString(),
      participantA: (map['participant_a'] ?? '').toString(),
      participantB: (map['participant_b'] ?? '').toString(),
      lastMessage: map['last_message'] as String?,
      lastSenderId: map['last_sender_id'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'] as String)
          : null,
      unreadA: (map['unread_a'] as int?) ?? 0,
      unreadB: (map['unread_b'] as int?) ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      otherUserName: map['other_user_name'] as String?,
      otherUserAvatar: map['other_user_avatar'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'participant_a': participantA,
    'participant_b': participantB,
    'last_message': lastMessage,
    'last_message_at': lastMessageAt?.toIso8601String(),
    'last_sender_id': lastSenderId,
    'unread_a': unreadA,
    'unread_b': unreadB,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'other_user_name': otherUserName,
    'other_user_avatar': otherUserAvatar,
  };

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastSenderId,
    int? unreadA,
    int? unreadB,
    DateTime? updatedAt,
    String? otherUserName,
    String? otherUserAvatar,
  }) => ConversationModel(
    id: id,
    participantA: participantA,
    participantB: participantB,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    lastSenderId: lastSenderId ?? this.lastSenderId,
    unreadA: unreadA ?? this.unreadA,
    unreadB: unreadB ?? this.unreadB,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    otherUserName: otherUserName ?? this.otherUserName,
    otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PresenceModel
// ─────────────────────────────────────────────────────────────────────────────

class PresenceModel {
  final String userId;
  final bool isOnline;
  final DateTime lastSeenAt;
  final String? typingIn; // conversationId or null

  const PresenceModel({
    required this.userId,
    required this.isOnline,
    required this.lastSeenAt,
    this.typingIn,
  });

  bool isTypingIn(String conversationId) => typingIn == conversationId;

  /// True only if the DB flag is set AND the last heartbeat was within 5 minutes.
  /// This prevents stale "online" badges when the user closed the app without
  /// the setOffline() call completing (e.g. force-killed app).
  bool get isOnlineNow {
    if (!isOnline) return false;
    final staleness = DateTime.now().difference(lastSeenAt);
    return staleness.inMinutes < 5;
  }

  factory PresenceModel.fromMap(Map<String, dynamic> map) {
    return PresenceModel(
      userId: (map['user_id'] ?? '').toString(),
      isOnline: (map['is_online'] as bool?) ?? false,
      lastSeenAt: map['last_seen_at'] != null
          ? DateTime.parse(map['last_seen_at'] as String)
          : DateTime.now(),
      typingIn: map['typing_in'] as String?,
    );
  }
}
