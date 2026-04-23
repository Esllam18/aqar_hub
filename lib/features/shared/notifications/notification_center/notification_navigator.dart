// lib/features/shared/notifications/notification_center/notification_navigator.dart
//
// Handles deep-link navigation from both live FCM taps and
// notification-center history row taps.
//
// Supported types:
//   new_message → open the specific chat conversation
//   new_property → open the property details screen
//   new_comment  → open the property that received the comment

import 'package:aqar_hub/features/house_seeker/home/data/datasources/property_datasource_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/data/repositories/property_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:aqar_hub/features/shared/notifications/notification_payload.dart';
import 'package:flutter/material.dart';
import 'notification_log_model.dart';

abstract final class NotificationNavigator {
  // ── From live FCM tap ──────────────────────────────────────────────────────

  static Future<void> navigateFromPayload(
    BuildContext context,
    NotificationPayload payload, {
    required void Function(int) onSwitchTab,
  }) async {
    if (payload.isChat) {
      onSwitchTab(1);
      if (payload.conversationId?.isNotEmpty == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!context.mounted) return;
        await ChatNavigator.openChatByConversationId(
          context,
          conversationId: payload.conversationId!,
          otherUserId: payload.senderId ?? '',
        );
      }
    } else if (payload.isProperty || payload.isComment) {
      // Both property and comment notifications navigate to property details.
      // Switch to home tab first so the back button returns the user there.
      onSwitchTab(0);
      final propertyId = payload.propertyId;
      if (propertyId?.isNotEmpty == true) {
        await Future.delayed(const Duration(milliseconds: 350));
        if (!context.mounted) return;
        await _openPropertyById(context, propertyId!);
      }
    }
  }

  // ── From notification center history tap ───────────────────────────────────

  static Future<void> navigateFromLog(
    BuildContext context,
    NotificationLogModel log, {
    required void Function(int) onSwitchTab,
  }) async {
    // Close the notification center drawer first
    Navigator.of(context).pop();

    if (log.isChat && log.conversationId.isNotEmpty) {
      onSwitchTab(1);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!context.mounted) return;
      await ChatNavigator.openChatByConversationId(
        context,
        conversationId: log.conversationId,
        otherUserId: '',
      );
    } else if ((log.isProperty || log.isComment) && log.propertyId.isNotEmpty) {
      onSwitchTab(0);
      await Future.delayed(const Duration(milliseconds: 350));
      if (!context.mounted) return;
      await _openPropertyById(context, log.propertyId);
    }
  }

  // ── Private: fetch property by ID and push details screen ─────────────────

  static Future<void> _openPropertyById(
    BuildContext context,
    String propertyId,
  ) async {
    try {
      final repo = PropertyRepositoryImpl(PropertyDatasourceImpl());
      final property = await repo.getPropertyById(propertyId);
      if (property == null || !context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailsView(property: property),
        ),
      );
    } catch (e) {
      debugPrint('[NotificationNavigator] _openPropertyById error: $e');
    }
  }
}
