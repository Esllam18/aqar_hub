import 'package:aqar_hub/features/owner/add_property/data/datasources/add_property_remote_datasource.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPropertyRepositoryImpl {
  final AddPropertyRemoteDatasource _datasource;
  final SupabaseClient _supabase = Supabase.instance.client;
  AddPropertyRepositoryImpl(this._datasource);

  /// Uploads media, inserts property, inserts rental options.
  /// Returns the new property id.
  Future<String> addProperty(AddPropertyFormModel form) async {
    final supabase = await _getOwnerId();

    // 1. Upload images (required)
    final imageUrls = await _datasource.uploadImages(
      ownerId: supabase,
      files: form.localImages,
    );

    // 2. Upload video (optional)
    String? videoUrl;
    if (form.localVideo != null) {
      videoUrl = await _datasource.uploadVideo(
        ownerId: supabase,
        file: form.localVideo!,
      );
    }

    // 3. Build insert map (AI result merged inside toInsertMap)
    final data = form.toInsertMap(
      ownerId: supabase,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
    );

    // 4. Insert property row
    final propertyId = await _datasource.insertProperty(data);

    // 5. Insert rental options (rent only)
    if (form.isRent && form.rentalOptions.isNotEmpty) {
      final options = form.rentalOptions
          .map((o) => o.toMap(propertyId))
          .toList();
      await _datasource.insertRentalOptions(options);
    }

    return propertyId;
  }

  Future<String> _getOwnerId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: expose _supabase for _getOwnerId — alternatively pass ownerId in
// through the form. If you want to avoid accessing the private field,
// replace _getOwnerId() with:
//
//   final ownerId = Supabase.instance.client.auth.currentUser?.id ?? '';
//
// directly in addProperty().
// ─────────────────────────────────────────────────────────────────────────────
