// lib/features/shared/notifications/notification_channel.dart
//
// Single source of truth for the Android notification channel.
// Both FcmService and the AndroidManifest meta-data use the same channelId.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract final class NotificationChannel {
  static const String id = 'aqarhub_main';
  static const String name = 'AqarHub Notifications';
  static const String description = 'Property listings and chat messages';

  /// The Android channel registered at app start.
  static const AndroidNotificationChannel main = AndroidNotificationChannel(
    id,
    name,
    description: description,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Full NotificationDetails used when showing a local notification.
  static const NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      id,
      name,
      channelDescription: description,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
