import 'package:aqar_hub/features/shared/chat/presentation/views/chat_conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/shared/chat/data/datasources/chat_remote_datasource.dart';
import 'package:aqar_hub/features/shared/chat/data/repositories/chat_repository_impl.dart';

class ChatNavigator {
  static Future<void> openChat(
    BuildContext context, {
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
    PropertyModel? property,
  }) async {
    try {
      final repo = ChatRepositoryImpl(ChatRemoteDatasource());
      final conversationId = await repo.openConversation(otherUserId);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationView(
            conversationId: conversationId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserAvatar: otherUserAvatar,
            // Pass property meta so the view can send the card once loaded
            initialPropertyCard: property != null
                ? PropertyCardMeta(
                    propertyId: property.id,
                    title: property.title,
                    city: property.city,
                    imageUrl: property.firstImage,
                    price: property.displayPrice,
                    isForSale: property.isForSale,
                  )
                : null,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
