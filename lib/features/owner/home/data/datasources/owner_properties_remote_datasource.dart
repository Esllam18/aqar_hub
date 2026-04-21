import 'dart:io';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerPropertiesRemoteDatasource {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _imageBucket = 'properties';

  static const String _select = '''
    *,
    rental_options(*)
  ''';

  Future<List<Map<String, dynamic>>> fetchOwnerProperties(
    String ownerId,
  ) async {
    final response = await _supabase
        .from('properties')
        .select(_select)
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateDescription({
    required String propertyId,
    required String description,
  }) async {
    await _supabase
        .from('properties')
        .update({'description': description})
        .eq('id', propertyId);
  }

  Future<void> updateRentedStatus({
    required String propertyId,
    required bool isRented,
  }) async {
    await _supabase
        .from('properties')
        .update({'is_rented': isRented})
        .eq('id', propertyId);
  }

  Future<void> updateRentalAvailability({
    required String optionId,
    required int availableQuantity,
  }) async {
    await _supabase
        .from('rental_options')
        .update({'available_quantity': availableQuantity})
        .eq('id', optionId);
  }

  Future<void> deleteProperty(String propertyId) async {
    await _supabase.from('properties').delete().eq('id', propertyId);
  }

  /// Update any subset of property fields
  Future<void> updateProperty({
    required String propertyId,
    required Map<String, dynamic> fields,
  }) async {
    await _supabase.from('properties').update(fields).eq('id', propertyId);
  }

  /// Upsert rental options (insert or update by id)
  Future<void> upsertRentalOptions({
    required String propertyId,
    required List<RentalOptionModel> options,
  }) async {
    final payload = options
        .map(
          (o) => {
            if (o.id.isNotEmpty) 'id': o.id,
            'property_id': propertyId,
            'type': o.type,
            'price': o.price,
            'total_quantity': o.totalQuantity,
            'available_quantity': o.availableQuantity,
          },
        )
        .toList();
    await _supabase.from('rental_options').upsert(payload);
  }

  Future<void> deleteRentalOption(String optionId) async {
    await _supabase.from('rental_options').delete().eq('id', optionId);
  }

  /// Upload new image files to Supabase Storage and return their public URLs.
  Future<List<String>> uploadImages({
    required String ownerId,
    required List<File> files,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      final name =
          '${DateTime.now().millisecondsSinceEpoch}_${urls.length}.$ext';
      final storagePath = '$ownerId/$name';
      final bytes = await file.readAsBytes();
      await _supabase.storage
          .from(_imageBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
              cacheControl: '3600',
            ),
          );
      urls.add(
        _supabase.storage.from(_imageBucket).getPublicUrl(storagePath),
      );
    }
    return urls;
  }
}
