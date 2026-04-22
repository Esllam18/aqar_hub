import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:aqar_hub/features/shared/notifications/notification_payload.dart';
import 'package:flutter/material.dart';
import 'notification_log_model.dart';

abstract final class NotificationNavigator {
  /// Navigate from a live FCM tap payload.
  static Future<void> navigateFromPayload(
    BuildContext context,
    NotificationPayload payload, {
    required void Function(int) onSwitchTab,
  }) async {
    if (payload.isChat) {
      // Switch to the chat tab first
      onSwitchTab(1);

      // If we have a specific conversationId, open that conversation directly
      if (payload.conversationId != null &&
          payload.conversationId!.isNotEmpty) {
        // Small delay to let the tab animation settle
        await Future.delayed(const Duration(milliseconds: 300));
        if (!context.mounted) return;

        await ChatNavigator.openChatByConversationId(
          context,
          conversationId: payload.conversationId!,
          otherUserId: payload.senderId ?? '',
        );
      }
    } else if (payload.isProperty) {
      onSwitchTab(0);
    }
  }

  /// Navigate from a notification history row tap.
  static Future<void> navigateFromLog(
    BuildContext context,
    NotificationLogModel log, {
    required void Function(int) onSwitchTab,
  }) async {
    Navigator.of(context).pop(); // Close notification center first

    if (log.isChat && log.conversationId.isNotEmpty) {
      onSwitchTab(1);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!context.mounted) return;

      await ChatNavigator.openChatByConversationId(
        context,
        conversationId: log.conversationId,
        otherUserId: '',
      );
    } else if (log.isProperty && log.propertyId.isNotEmpty) {
      onSwitchTab(0);
    }
  }
}
