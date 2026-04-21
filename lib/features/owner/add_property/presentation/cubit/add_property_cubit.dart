import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'package:aqar_hub/features/owner/add_property/data/repositories/add_property_repository_impl.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/cubit/add_property_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPropertyCubit extends Cubit<AddPropertyState> {
  final AddPropertyRepositoryImpl repository;

  AddPropertyCubit(this.repository) : super(const AddPropertyInitial());

  Future<void> submit(AddPropertyFormModel form) async {
    emit(const AddPropertyLoading());
    try {
      final propertyId = await repository.addProperty(form);

      await _notifyNewProperty(form.title, propertyId);

      emit(AddPropertySuccess(propertyId));
    } catch (e) {
      emit(AddPropertyError(_mapError(e)));
    }
  }

  Future<void> _notifyNewProperty(String title, String propertyId) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      // Insert a notification_log record so seekers who load the app
      // can see the new property notification in their history.
      // The FCM topic message is handled by Firebase Cloud Messaging directly
      // when the Edge Function is set up — see NOTIFICATIONS_SETUP.md.
      await Supabase.instance.client.from('notification_log').insert({
        'recipient_id': uid, // owner sees it too
        'sender_id': uid,
        'type': 'new_property',
        'title': 'عقار جديد',
        'body': title,
        'data': {'property_id': propertyId, 'type': 'new_property'},
        'is_read': false,
      });
    } catch (e) {
      // Non-fatal — property was saved successfully
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
