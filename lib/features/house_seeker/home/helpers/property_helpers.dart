import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class PropertyHelpers {
  static String greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'home_greeting_morning'.tr(context);
    if (hour >= 12 && hour < 17) return 'home_greeting_afternoon'.tr(context);
    return 'home_greeting_evening'.tr(context);
  }

  static String formatPrice(double price, BuildContext context) {
    final formatted = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '$formatted ${'currency'.tr(context)}';
  }

  static String rentalTypeLabel(String type, BuildContext context) =>
      switch (type) {
        'bed' => 'rental_bed'.tr(context),
        'room' => 'rental_room'.tr(context),
        'apartment' => 'rental_apartment'.tr(context),
        _ => type,
      };

  static String audienceLabel(String audience, BuildContext context) =>
      switch (audience) {
        'male' => 'audience_male'.tr(context),
        'female' => 'audience_female'.tr(context),
        'family' => 'audience_family'.tr(context),
        _ => 'audience_all'.tr(context),
      };

  /// Reads first name from auth metadata (fast, no network call)
  static String currentUserFirstName() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    final fullName =
        meta['full_name'] as String? ?? meta['name'] as String? ?? '';
    if (fullName.isNotEmpty) return fullName.split(' ').first;
    return '';
  }

  /// Reads first name from profiles table (accurate, async)
  static Future<String> fetchUserFirstName() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return '';
      final data = await Supabase.instance.client
          .from('profiles')
          .select('first_name')
          .eq('id', userId)
          .maybeSingle();
      return (data?['first_name'] as String?) ?? currentUserFirstName();
    } catch (_) {
      return currentUserFirstName();
    }
  }

  static String propertyTypeLabel(String? type) => switch (type) {
    'apartment' => 'شقة',
    'villa' => 'فيلا',
    'studio' => 'استوديو',
    'penthouse' => 'بنتهاوس',
    'duplex' => 'دوبلكس',
    'chalet' => 'شاليه',
    _ => '',
  };
  static String locationLabel(dynamic property) {
    final parts = <String>[];
    if (property.city.isNotEmpty) parts.add(property.city);
    if (property.address.isNotEmpty) parts.add(property.address);
    return parts.join(' - ');
  }
}
