// lib/features/shared/notifications/notification_payload.dart
//
// Strongly-typed model for FCM notification data payloads.
// Keeps navigation logic out of FcmService.

class NotificationPayload {
  final String type;
  final String? conversationId;
  final String? propertyId;
  final String? senderId;

  const NotificationPayload({
    required this.type,
    this.conversationId,
    this.propertyId,
    this.senderId,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type'] as String? ?? 'general',
      conversationId: map['conversation_id'] as String?,
      propertyId: map['property_id'] as String?,
      senderId: map['sender_id'] as String?,
    );
  }

  /// True when tapping should navigate to the chat screen.
  bool get isChat => type == 'new_message';

  /// True when tapping should navigate to the home/property screen.
  bool get isProperty => type == 'new_property';
}
