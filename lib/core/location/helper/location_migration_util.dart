import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'egypt_location_helper.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';

/// Summary returned by [LocationMigrationUtil.run].
class MigrationReport {
  final int updated;
  final int unresolved;
  final int skipped;
  final List<String> unresolvedIds;

  const MigrationReport({
    required this.updated,
    required this.unresolved,
    required this.skipped,
    required this.unresolvedIds,
  });

  @override
  String toString() =>
      '[Migration] Done. updated=$updated, unresolved=$unresolved, '
      'skipped=$skipped\n'
      'Unresolved IDs: $unresolvedIds';
}

abstract final class LocationMigrationUtil {
  static SupabaseClient get _db => Supabase.instance.client;

  static Future<MigrationReport> run({bool dryRun = false}) async {
    int updated = 0;
    int unresolved = 0;
    int skipped = 0;
    final unresolvedIds = <String>[];

    final rows = await _db
        .from('properties')
        .select(
          'id, governorate_slug, city_slug, area_slug, city, location_path',
        );

    for (final row in rows as List<dynamic>) {
      final id = row['id'] as String;
      final rawGov = (row['governorate_slug'] as String? ?? '').trim();
      final rawCity =
          ((row['city_slug'] as String? ?? '').isNotEmpty
                  ? row['city_slug'] as String
                  : row['city'] as String? ?? '')
              .trim();
      final rawArea = (row['area_slug'] as String? ?? '').trim();

      if (rawGov.isEmpty) {
        skipped++;
        continue;
      }

      // ── 1. Resolve governorate ───────────────────────────────────────────
      final govSlug = EgyptLocationHelper.canonicalGovernorateSlug(rawGov);
      final govNode = EgyptLocations.findGovernorate(govSlug);

      if (govNode == null) {
        debugPrint('[Migration] [$id] UNRESOLVED gov "$rawGov"');
        unresolved++;
        unresolvedIds.add(id);
        continue;
      }

      // ── 2. Resolve city ──────────────────────────────────────────────────
      String citySlug = '';
      if (rawCity.isNotEmpty) {
        citySlug = EgyptLocationHelper.canonicalCitySlug(
          governorateSlug: govSlug,
          raw: rawCity,
        );
        final cityNode = EgyptLocations.findCity(
          governorateSlug: govSlug,
          citySlug: citySlug,
        );
        if (cityNode == null) {
          // City couldn't be resolved — still continue so we at least fix gov
          debugPrint(
            '[Migration] [$id] UNRESOLVED city "$rawCity" (gov: $govSlug)',
          );
          citySlug = ''; // don't write a bad slug
        }
      }

      // ── 3. Resolve area ──────────────────────────────────────────────────
      String areaSlug = '';
      if (rawArea.isNotEmpty && citySlug.isNotEmpty) {
        areaSlug = EgyptLocationHelper.canonicalAreaSlug(
          governorateSlug: govSlug,
          citySlug: citySlug,
          raw: rawArea,
        );
        final areaNode = EgyptLocations.findArea(
          governorateSlug: govSlug,
          citySlug: citySlug,
          areaSlug: areaSlug,
        );
        if (areaNode == null) {
          debugPrint(
            '[Migration] [$id] UNRESOLVED area "$rawArea" '
            '(gov: $govSlug, city: $citySlug)',
          );
          areaSlug = '';
        }
      }

      // ── 4. Check if anything actually changed ────────────────────────────
      final oldGov = rawGov;
      final oldCity = (row['city_slug'] as String? ?? '').trim();
      final oldArea = rawArea;

      final govChanged = govSlug != oldGov && govSlug.isNotEmpty;
      final cityChanged = citySlug != oldCity && citySlug.isNotEmpty;
      final areaChanged = areaSlug != oldArea && areaSlug.isNotEmpty;

      // Also check if slugs are already correct but location_path is stale
      final newPath = EgyptLocations.buildLocationPath(
        governorateSlug: govSlug,
        citySlug: citySlug.isEmpty ? null : citySlug,
        areaSlug: areaSlug.isEmpty ? null : areaSlug,
      );
      final pathChanged =
          newPath != (row['location_path'] as String? ?? '').trim();

      if (!govChanged && !cityChanged && !areaChanged && !pathChanged) {
        skipped++;
        continue;
      }

      debugPrint(
        '[Migration] [$id] '
        'gov: "$oldGov" → "$govSlug" | '
        'city: "$oldCity" → "$citySlug" | '
        'area: "$oldArea" → "$areaSlug"',
      );

      if (!dryRun) {
        await _updateRow(
          id: id,
          govSlug: govSlug,
          citySlug: citySlug,
          areaSlug: areaSlug,
          locationPath: newPath,
        );
      }
      updated++;
    }

    final report = MigrationReport(
      updated: updated,
      unresolved: unresolved,
      skipped: skipped,
      unresolvedIds: unresolvedIds,
    );
    debugPrint(report.toString());
    return report;
  }

  static Future<void> _updateRow({
    required String id,
    required String govSlug,
    required String citySlug,
    required String areaSlug,
    required String locationPath,
  }) async {
    await _db
        .from('properties')
        .update({
          'governorate_slug': govSlug.isEmpty ? null : govSlug,
          'city_slug': citySlug.isEmpty ? null : citySlug,
          'area_slug': areaSlug.isEmpty ? null : areaSlug,
          'city': citySlug.isNotEmpty ? citySlug : govSlug,
          'location_path': locationPath.isEmpty ? null : locationPath,
        })
        .eq('id', id);
  }
}
