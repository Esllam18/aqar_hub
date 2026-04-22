import 'package:aqar_hub/features/shared/chat/presentation/views/chat_conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/shared/chat/data/datasources/chat_remote_datasource.dart';
import 'package:aqar_hub/features/shared/chat/data/repositories/chat_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatNavigator {
  /// Open a conversation from a property listing — creates conversation if needed.
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

  /// Open a specific conversation by ID — used when tapping a push notification.
  /// Fetches the other user's profile from the conversations table.
  static Future<void> openChatByConversationId(
    BuildContext context, {
    required String conversationId,
    required String otherUserId,
  }) async {
    try {
      final db = Supabase.instance.client;
      final myId = db.auth.currentUser?.id;
      if (myId == null) return;

      // Fetch the conversation to identify the other participant
      final conv = await db
          .from('conversations')
          .select('participant_a, participant_b')
          .eq('id', conversationId)
          .maybeSingle();

      if (conv == null) return;

      final actualOtherId = (conv['participant_a'] as String) == myId
          ? conv['participant_b'] as String
          : conv['participant_a'] as String;

      // Fetch the other user's profile
      final profile = await db
          .from('profiles')
          .select('first_name, last_name, profile_image_url')
          .eq('id', actualOtherId)
          .maybeSingle();

      if (!context.mounted) return;

      final firstName = (profile?['first_name'] ?? '').toString();
      final lastName = (profile?['last_name'] ?? '').toString();
      final name = '$firstName $lastName'.trim();
      final avatar = profile?['profile_image_url'] as String?;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationView(
            conversationId: conversationId,
            otherUserId: actualOtherId,
            otherUserName: name,
            otherUserAvatar: avatar,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[ChatNavigator] openChatByConversationId error: $e');
    }
  }
}
