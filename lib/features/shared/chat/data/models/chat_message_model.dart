// lib/features/shared/chat/data/models/chat_message_model.dart

import 'dart:convert';

// ── Message type ──────────────────────────────────────────────────────────────
//
// propertyCard is stored as message_type = 'text' in Supabase but content
// starts with the sentinel prefix "property_card:" followed by JSON.
// This keeps the DB schema unchanged (no migration needed).
// ─────────────────────────────────────────────────────────────────────────────

enum MessageType { text, image, video, voice, propertyCard }

// ── Embedded property metadata (for propertyCard messages) ───────────────────

class PropertyCardMeta {
  final String propertyId;
  final String title;
  final String city;
  final String? imageUrl;
  final double? price;
  final bool isForSale;

  const PropertyCardMeta({
    required this.propertyId,
    required this.title,
    required this.city,
    this.imageUrl,
    this.price,
    required this.isForSale,
  });

  Map<String, dynamic> toJson() => {
    'propertyId': propertyId,
    'title': title,
    'city': city,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (price != null) 'price': price,
    'isForSale': isForSale,
  };

  factory PropertyCardMeta.fromJson(Map<String, dynamic> j) => PropertyCardMeta(
    propertyId: (j['propertyId'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    city: (j['city'] ?? '').toString(),
    imageUrl: j['imageUrl'] as String?,
    price: (j['price'] as num?)?.toDouble(),
    isForSale: (j['isForSale'] as bool?) ?? false,
  );

  /// Encode as string embedded in message content.
  String toContentString() => 'property_card:${jsonEncode(toJson())}';

  /// Attempt to parse from a raw content string.
  static PropertyCardMeta? tryParseContent(String? content) {
    if (content == null || !content.startsWith('property_card:')) return null;
    try {
      final payload = content.substring('property_card:'.length);
      return PropertyCardMeta.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

// ── Chat message model ────────────────────────────────────────────────────────

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String? content; // text body OR property_card JSON sentinel
  final String? mediaUrl; // image / video / voice
  final int? durationSecs; // voice only
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.durationSecs,
    required this.isRead,
    required this.createdAt,
  });

  bool get isVoice => type == MessageType.voice;
  bool get isImage => type == MessageType.image;
  bool get isVideo => type == MessageType.video;
  bool get isText => type == MessageType.text;
  bool get isPropertyCard => type == MessageType.propertyCard;

  /// Non-null when this message is a property card.
  PropertyCardMeta? get propertyCard =>
      PropertyCardMeta.tryParseContent(content);

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    final rawType = map['message_type']?.toString();
    final content = map['content'] as String?;

    // Detect propertyCard sentinel stored as message_type='text'
    MessageType type;
    if (rawType == 'text' &&
        content != null &&
        content.startsWith('property_card:')) {
      type = MessageType.propertyCard;
    } else {
      type = _parseType(rawType);
    }

    return ChatMessageModel(
      id: (map['id'] ?? '').toString(),
      conversationId: (map['conversation_id'] ?? '').toString(),
      senderId: (map['sender_id'] ?? '').toString(),
      type: type,
      content: content,
      mediaUrl: map['media_url'] as String?,
      durationSecs: map['duration_secs'] as int?,
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'conversation_id': conversationId,
    'sender_id': senderId,
    // propertyCard is stored as 'text' in DB
    'message_type': type == MessageType.propertyCard ? 'text' : type.name,
    if (content != null) 'content': content,
    if (mediaUrl != null) 'media_url': mediaUrl,
    if (durationSecs != null) 'duration_secs': durationSecs,
  };

  static MessageType _parseType(dynamic raw) {
    switch (raw?.toString()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }

  ChatMessageModel copyWith({bool? isRead, String? mediaUrl}) =>
      ChatMessageModel(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        type: type,
        content: content,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        durationSecs: durationSecs,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
