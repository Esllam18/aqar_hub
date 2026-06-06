// lib/features/owner/add_property/data/datasources/add_property_remote_datasource.dart
//
// No changes needed here — the datasource receives a pre-built `Map<String, dynamic>`
// from [AddPropertyFormModel.toInsertMap()] which now always contains slug values.

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPropertyRemoteDatasource {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _imageBucket = 'properties';
  static const String _videoBucket = 'property_videos';

  // ── Upload images ─────────────────────────────────────────────────────────

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

      await _supabase.storage.from(_imageBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
              cacheControl: '3600',
            ),
          );
      urls.add(
          _supabase.storage.from(_imageBucket).getPublicUrl(storagePath));
    }
    return urls;
  }

  Future<String?> uploadVideo({
    required String ownerId,
    required File file,
  }) async {
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final safeExt =
        ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp'].contains(ext)
            ? ext
            : 'mp4';
    final name = '${DateTime.now().millisecondsSinceEpoch}_video.$safeExt';
    final storagePath = '$ownerId/$name';
    final bytes = await file.readAsBytes();

    await _supabase.storage.from(_videoBucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'video/$safeExt',
            upsert: true,
            cacheControl: '3600',
          ),
        );
    return _supabase.storage.from(_videoBucket).getPublicUrl(storagePath);
  }

  // ── Insert property ───────────────────────────────────────────────────────

  /// Inserts a property row and returns the new property id.
  /// [data] must come from [AddPropertyFormModel.toInsertMap()] so all
  /// location columns contain canonical slugs.
  Future<String> insertProperty(Map<String, dynamic> data) async {
    final result = await _supabase
        .from('properties')
        .insert(data)
        .select('id')
        .single();
    return result['id'] as String;
  }

  // ── Bulk-insert rental options ────────────────────────────────────────────

  Future<void> insertRentalOptions(List<Map<String, dynamic>> options) async {
    if (options.isEmpty) return;
    await _supabase.from('rental_options').insert(options);
  }
}
