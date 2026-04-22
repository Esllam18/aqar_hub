import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'package:aqar_hub/features/owner/add_property/data/repositories/add_property_repository_impl.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/cubit/add_property_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPropertyCubit extends Cubit<AddPropertyState> {
  final AddPropertyRepositoryImpl repository;

  AddPropertyCubit(this.repository) : super(const AddPropertyInitial());

  Future<void> submit(AddPropertyFormModel form) async {
    emit(const AddPropertyLoading());
    try {
      final propertyId = await repository.addProperty(form);

      // Broadcast the new listing to all seekers
      await _broadcastNewProperty(
        title: form.title,
        propertyId: propertyId,
        governorateSlug: form.governorateSlug,
        listingType: form.listingType,
      );

      emit(AddPropertySuccess(propertyId));
    } catch (e) {
      emit(AddPropertyError(_mapError(e)));
    }
  }

  /// Notifies seekers of a new property listing.
  ///
  /// Strategy:
  ///   1. Call the `send-push-notification` Edge Function — it fans out an
  ///      FCM push to all seeker device tokens via the server-side Firebase
  ///      Admin SDK (topic: "new_listings").
  ///   2. Insert a single notification_log row for each seeker so they see
  ///      the notification in their in-app notification center even when
  ///      the app was closed.
  ///
  /// Both steps are best-effort: a failure here must never block the property
  /// from being published successfully.
  Future<void> _broadcastNewProperty({
    required String title,
    required String propertyId,
    String? governorateSlug,
    required String listingType,
  }) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      // ── Step 1: Push all seekers via Edge Function ─────────────────────────
      // The Edge Function reads all device_tokens for users whose role = 'user'
      // (seekers) and sends an FCM notification to each one.
      await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'type': 'new_property',
          'property_id': propertyId,
          'title_ar': 'عقار جديد',
          'title_en': 'New Listing',
          'body_ar': title,
          'body_en': title,
          'sender_id': uid,
          'governorate_slug': governorateSlug,
          'listing_type': listingType,
        },
      );
    } catch (e) {
      // Edge Function failure is non-fatal — property is already saved.
      debugPrint('[AddProperty] push notification failed (non-fatal): $e');
    }

    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      // ── Step 2: Insert notification_log rows for all seekers ───────────────
      // Fetch all seeker user IDs so each one sees the notification in-app.
      final seekers = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('role', 'user');

      final rows = (seekers as List)
          .map(
            (s) => {
              'recipient_id': s['id'] as String,
              'sender_id': uid,
              'type': 'new_property',
              'title': 'عقار جديد',
              'body': title,
              'data': {'property_id': propertyId, 'type': 'new_property'},
              'is_read': false,
            },
          )
          .toList();

      if (rows.isNotEmpty) {
        // Insert in a single batch — no N+1 queries.
        await Supabase.instance.client.from('notification_log').insert(rows);
      }
    } catch (e) {
      debugPrint(
        '[AddProperty] notification_log insert failed (non-fatal): $e',
      );
    }
  }

  String _mapError(Object error) {
    if (error is StorageException) {
      final msg = error.message;
      if (msg.toLowerCase().contains('bucket')) {
        return 'Storage bucket not found. '
            'Please make sure the "properties" and "property_videos" '
            'buckets exist and are Public in Supabase dashboard.\n'
            'Detail: $msg';
      }
      return msg;
    }
    if (error is PostgrestException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Database request failed.';
    }
    if (error is AuthException) return error.message;
    return error.toString();
  }
}
