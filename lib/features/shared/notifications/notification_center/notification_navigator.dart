import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/features/house_seeker/home/data/datasources/property_datasource_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/data/repositories/property_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:aqar_hub/features/shared/notifications/notification_payload.dart';
import 'package:flutter/material.dart';
import 'notification_log_model.dart';

abstract final class NotificationNavigator {
  static Future<void> navigateFromPayload(
    BuildContext context, // kept for API compatibility but not used for push
    NotificationPayload payload, {
    required void Function(int) onSwitchTab,
  }) async {
    if (payload.isChat) {
      onSwitchTab(1);
      final convId = payload.conversationId ?? '';
      if (convId.isNotEmpty) {
        // Small delay so the tab animation completes before the push
        await Future.delayed(const Duration(milliseconds: 200));
        await _openChatByConversationId(convId);
      }
    } else if (payload.isProperty || payload.isComment) {
      onSwitchTab(0);
      final propertyId = payload.propertyId ?? '';
      if (propertyId.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        await _openPropertyById(propertyId);
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
      await Future.delayed(const Duration(milliseconds: 200));
      await _openChatByConversationId(log.conversationId);
    } else if ((log.isProperty || log.isComment) && log.propertyId.isNotEmpty) {
      onSwitchTab(0);
      await Future.delayed(const Duration(milliseconds: 200));
      await _openPropertyById(log.propertyId);
    }
  }

  // ── Shared: open chat via root navigator ──────────────────────────────────

  static Future<void> _openChatByConversationId(String conversationId) async {
    // FIX: use Navigation.key.currentContext which is always the root
    // MaterialApp context, not a stale or child widget context.
    final ctx = Navigation.key.currentContext;
    if (ctx == null) {
      debugPrint(
        '[NotificationNavigator] root context is null — app not ready yet',
      );
      return;
    }
    await ChatNavigator.openChatByConversationId(
      ctx,
      conversationId: conversationId,
      otherUserId: '',
    );
  }

  // ── Shared: fetch property and push detail screen via root navigator ──────

  static Future<void> _openPropertyById(String propertyId) async {
    final ctx = Navigation.key.currentContext;
    if (ctx == null) {
      debugPrint(
        '[NotificationNavigator] root context is null — app not ready yet',
      );
      return;
    }
    try {
      final repo = PropertyRepositoryImpl(PropertyDatasourceImpl());
      final property = await repo.getPropertyById(propertyId);
      if (property == null) return;

      // Re-fetch the context after the async gap — it may have changed
      final freshCtx = Navigation.key.currentContext;
      if (freshCtx == null) return;

      Navigator.push(
        // ignore: use_build_context_synchronously
        freshCtx,
        MaterialPageRoute(
          builder: (_) => PropertyDetailsView(property: property),
        ),
      );
    } catch (e) {
      debugPrint('[NotificationNavigator] _openPropertyById error: $e');
    }
  }
}
