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
      final convId = payload.conversationId ?? '';
      if (convId.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 350));
        if (!context.mounted) return;
        await ChatNavigator.openChatByConversationId(
          context,
          conversationId: convId,
          otherUserId: payload.senderId ?? '',
        );
      }
    } else if (payload.isProperty || payload.isComment) {
      // Switch to home tab so back-button lands there
      onSwitchTab(0);
      final propertyId = payload.propertyId ?? '';
      if (propertyId.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 350));
        if (!context.mounted) return;
        await _openPropertyById(context, propertyId);
      }
    }
  }

  // ── From notification history tap ─────────────────────────────────────────

  static Future<void> navigateFromLog(
    BuildContext context,
    NotificationLogModel log, {
    required void Function(int) onSwitchTab,
  }) async {
    // Close the notification center screen first
    Navigator.of(context).pop();

    if (log.isChat && log.conversationId.isNotEmpty) {
      onSwitchTab(1);
      await Future.delayed(const Duration(milliseconds: 350));
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

  // ── Shared: fetch property and push detail screen ─────────────────────────

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
