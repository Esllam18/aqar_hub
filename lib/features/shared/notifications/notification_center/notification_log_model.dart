// lib/features/shared/notifications/notification_center/notification_log_model.dart
//
// Maps the notification_log Supabase table to a Dart model.

class NotificationLogModel {
  final String id;
  final String recipientId;
  final String? senderId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime sentAt;

  const NotificationLogModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationLogModel.fromMap(Map<String, dynamic> map) {
    return NotificationLogModel(
      id: map['id'] as String,
      recipientId: map['recipient_id'] as String,
      senderId: map['sender_id'] as String?,
      type: map['type'] as String? ?? 'general',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(map['sent_at'] as String),
    );
  }

  // Convenience helpers for UI
  bool get isChat => type == 'new_message';
  bool get isProperty => type == 'new_property';

  String get conversationId => data?['conversation_id'] as String? ?? '';
  String get propertyId => data?['property_id'] as String? ?? '';

  NotificationLogModel copyWith({bool? isRead}) {
    return NotificationLogModel(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
    );
  }
}
