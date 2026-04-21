// lib/features/shared/notifications/notification_center/notification_navigator.dart
//
// Single place for all deep-link navigation triggered by notification taps.
// Used by both FcmService (live push) and NotificationCenterView (history tap).

import 'package:aqar_hub/features/shared/notifications/notification_payload.dart';
import 'package:flutter/material.dart';
import 'notification_log_model.dart';

abstract final class NotificationNavigator {
  /// Navigate from a live FCM tap payload.
  static void navigateFromPayload(
    BuildContext context,
    NotificationPayload payload, {
    required void Function(int) onSwitchTab,
  }) {
    if (payload.isChat) {
      onSwitchTab(1); // Jump to chat tab
    } else if (payload.isProperty) {
      onSwitchTab(0); // Jump to home tab
    }
  }

  /// Navigate from a notification history row tap.
  static void navigateFromLog(
    BuildContext context,
    NotificationLogModel log, {
    required void Function(int) onSwitchTab,
  }) {
    Navigator.of(context).pop(); // Close the notification center screen first

    if (log.isChat && log.conversationId.isNotEmpty) {
      onSwitchTab(1);
    } else if (log.isProperty && log.propertyId.isNotEmpty) {
      onSwitchTab(0);
    }
  }
}
