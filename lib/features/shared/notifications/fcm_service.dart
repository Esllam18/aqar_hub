import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/helpers/app_prefs.dart';
import 'notification_channel.dart';
import 'notification_payload.dart';

export 'notification_payload.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _fm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  void Function(NotificationPayload)? _onTap;

  // ── Public init ───────────────────────────────────────────────────────────

  Future<void> init() async {
    await _setupLocalNotifications();
    await _requestPermission();
    _listenTokenRefresh();
    _listenForeground();
    _listenBackground();
    await _handleTerminatedTap();
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final s = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] permission: ${s.authorizationStatus}');
  }

  // ── Local notifications ───────────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalTap,
    );
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(NotificationChannel.main);
    }
  }

  /// Show a local notification with the FCM data encoded as payload
  /// so that _onLocalTap can navigate to the right screen when tapped.
  void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    // Encode the message data as a JSON string payload
    // so the tap handler can parse it and navigate correctly.
    final payloadJson = jsonEncode(message.data);

    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationChannel.details,
      payload: payloadJson,
    );
  }

  /// Called when the user taps a local notification shown while app is foreground.
  void _onLocalTap(NotificationResponse details) {
    debugPrint('[FCM-LOCAL-TAP] ${details.payload}');
    final raw = details.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _onTap?.call(NotificationPayload.fromMap(data));
    } catch (e) {
      debugPrint('[FCM] _onLocalTap parse error: $e');
    }
  }

  // ── Listeners ─────────────────────────────────────────────────────────────

  void _listenTokenRefresh() {
    _fm.onTokenRefresh.listen((token) async {
      await AppPrefs.saveFcmToken(token);
      if (Supabase.instance.client.auth.currentUser != null) {
        await _upsertToken(token);
      }
    });
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('[FCM-FG] ${msg.notification?.title}');
      _showLocal(msg);
    });
  }

  void _listenBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('[FCM-TAP-BG] ${msg.data}');
      _onTap?.call(NotificationPayload.fromMap(msg.data));
    });
  }

  Future<void> _handleTerminatedTap() async {
    final msg = await _fm.getInitialMessage();
    if (msg == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTap?.call(NotificationPayload.fromMap(msg.data));
    });
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<void> registerTokenForCurrentUser() async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;
      await AppPrefs.saveFcmToken(token);
      await _upsertToken(token);
    } catch (e) {
      debugPrint('[FCM] registerToken error: $e');
    }
  }

  Future<void> _upsertToken(String token) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final platform = Platform.isIOS ? 'ios' : 'android';

      // Delete the old token(s) for this user+platform first, then insert the
      // new one. This avoids stale tokens accumulating (e.g. after reinstall)
      // and works even though device_tokens has no unique index.
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('user_id', uid)
          .eq('platform', platform);

      await Supabase.instance.client.from('device_tokens').insert({
        'user_id': uid,
        'token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('[FCM] token saved for $uid on $platform');
    } catch (e) {
      debugPrint('[FCM] _upsertToken error: $e');
    }
  }

  Future<void> removeToken() async {
    try {
      final token = AppPrefs.fcmToken;
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (token == null || token.isEmpty || uid == null) return;
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('user_id', uid)
          .eq('token', token);
      await AppPrefs.saveFcmToken('');
    } catch (e) {
      debugPrint('[FCM] removeToken error: $e');
    }
  }

  // ── Send push via Edge Function ───────────────────────────────────────────

  Future<void> sendPushToUser({
    required String recipientUid,
    required String title,
    required String body,
    String type = 'general',
    Map<String, String>? data,
  }) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'recipient_uid': recipientUid,
          'title': title,
          'body': body,
          'data': {'type': type, ...?data},
        },
      );
      await _logNotification(
        recipientUid: recipientUid,
        title: title,
        body: body,
        type: type,
        data: data,
      );
    } catch (e) {
      debugPrint('[FCM] sendPushToUser error: $e');
    }
  }

  Future<void> _logNotification({
    required String recipientUid,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      final senderUid = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('notification_log').insert({
        'recipient_id': recipientUid,
        if (senderUid != null) 'sender_id': senderUid,
        'type': type,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('[FCM] _logNotification error: $e');
    }
  }

  // ── Navigation handler ────────────────────────────────────────────────────

  /// Set by MainLayoutView after the navigator is ready.
  void setOnTap(void Function(NotificationPayload) handler) => _onTap = handler;
}
