// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_filter_model.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/cubit/home_cubit.dart';
import 'filter_location_sheet.dart';
import 'filter_sheet_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class FilterHelpers {
  // ── Translation helper ────────────────────────────────────────────────────
  static String tr(BuildContext ctx, String key, String fallback) {
    final v = key.tr(ctx);
    return v == key ? fallback : v;
  }

  static String money(BuildContext ctx, num value) {
    final fmt = value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '$fmt ${tr(ctx, 'currency', 'EGP')}';
  }

  // ── Apply ─────────────────────────────────────────────────────────────────
  static void apply(BuildContext ctx, PropertyFilterModel f) =>
      ctx.read<HomeCubit>().applyFilter(f);

  // ── Labels ────────────────────────────────────────────────────────────────
  static String listingLabel(BuildContext ctx, PropertyFilterModel f) =>
      switch (f.listingType) {
        'rent' => tr(ctx, 'homefilterrent', 'Rent'),
        'sale' => tr(ctx, 'homefiltersale', 'Sale'),
        _ => tr(ctx, 'filterlistingtype', 'Listing Type'),
      };

  static String rentalLabel(BuildContext ctx, PropertyFilterModel f) =>
      switch (f.rentalType) {
        'bed' => tr(ctx, 'rentalbed', 'Bed'),
        'room' => tr(ctx, 'rentalroom', 'Room'),
        'apartment' => tr(ctx, 'rentalapartment', 'Apartment'),
        _ => tr(ctx, 'filterrentaltype', 'Rental Type'),
      };

  static String locationLabel(BuildContext ctx, PropertyFilterModel f) {
    final city = EgyptLocations.findCity(
      governorateSlug: f.governorateSlug,
      citySlug: f.citySlug,
    );
    if (city != null) return city.label(ctx);
    final gov = EgyptLocations.findGovernorate(f.governorateSlug);
    if (gov != null) return gov.label(ctx);
    return tr(ctx, 'filtergovernorate', 'Governorate');
  }

  static bool hasLocation(PropertyFilterModel f) =>
      f.governorateSlug != null || f.citySlug != null;

  static String propTypeLabel(BuildContext ctx, PropertyFilterModel f) {
    const map = {
      'apartment': 'propertytypeapartment',
      'villa': 'propertytypevilla',
      'studio': 'propertytypestudio',
      'penthouse': 'propertytypepenthouse',
      'duplex': 'propertytypeduplex',
      'chalet': 'propertytypechalet',
    };
    return f.propertyType != null
        ? tr(ctx, map[f.propertyType!] ?? '', f.propertyType!)
        : tr(ctx, 'filterpropertytype', 'Property Type');
  }

  static String furnishedLabel(BuildContext ctx, PropertyFilterModel f) {
    if (f.isFurnished == true) {
      return tr(ctx, 'filterfurnishedyes', 'Furnished');
    }
    if (f.isFurnished == false) {
      return tr(ctx, 'filterfurnishedno', 'Unfurnished');
    }
    return tr(ctx, 'filterfurnished', 'Furnishing');
  }

  static String roomsLabel(BuildContext ctx, PropertyFilterModel f) =>
      f.minRooms == null
      ? tr(ctx, 'filterrooms', 'Rooms')
      : '${f.minRooms}+ ${tr(ctx, 'statrooms', 'rooms')}';

  static String bedsLabel(BuildContext ctx, PropertyFilterModel f) =>
      f.minBeds == null
      ? tr(ctx, 'filterbeds', 'Beds')
      : '${f.minBeds}+ ${tr(ctx, 'statbeds', 'beds')}';

  static String audienceLabel(BuildContext ctx, PropertyFilterModel f) {
    const map = {
      'male': 'audiencemale',
      'female': 'audiencefemale',
      'family': 'audiencefamily',
    };
    return f.targetAudience != null
        ? tr(ctx, map[f.targetAudience!] ?? '', f.targetAudience!)
        : tr(ctx, 'filteraudience', 'Tenant Type');
  }

  static String priceLabel(BuildContext ctx, PropertyFilterModel f) {
    if (f.minPrice == null && f.maxPrice == null) {
      return tr(ctx, 'filterprice', 'Price');
    }
    if (f.minPrice != null && f.maxPrice != null) {
      return '${money(ctx, f.minPrice!)} - ${money(ctx, f.maxPrice!)}';
    }
    if (f.minPrice != null) {
      return '${tr(ctx, 'filterfrom', 'From')} ${money(ctx, f.minPrice!)}';
    }
    return '${tr(ctx, 'filterupto', 'Up to')} ${money(ctx, f.maxPrice!)}';
  }

  // ── Sheet launchers ───────────────────────────────────────────────────────
  static void showChoice<T>(
    BuildContext ctx,
    String title,
    T? selected,
    List<({String label, T? value})> opts,
    ValueChanged<T?> onSel,
  ) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterChoiceSheet(
        title: title,
        children: opts
            .map(
              (o) => FilterSheetTile(
                label: o.label,
                isSelected: o.value == selected,
                onTap: () {
                  Navigator.pop(ctx);
                  onSel(o.value);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  static void showListingType(BuildContext ctx, PropertyFilterModel f) {
    showChoice<String>(
      ctx,
      tr(ctx, 'filterlistingtype', 'Listing Type'),
      f.listingType,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        (label: tr(ctx, 'homefilterrent', 'Rent'), value: 'rent'),
        (label: tr(ctx, 'homefiltersale', 'Sale'), value: 'sale'),
      ],
      (v) {
        if (v == null) {
          apply(
            ctx,
            f.copyWith(
              clearListingType: true,
              clearRentalType: true,
              clearTargetAudience: true,
              clearMinBeds: true,
            ),
          );
        } else if (v == 'sale')
          apply(
            ctx,
            f.copyWith(
              listingType: 'sale',
              clearRentalType: true,
              clearTargetAudience: true,
              clearMinBeds: true,
            ),
          );
        else
          apply(ctx, f.copyWith(listingType: 'rent'));
      },
    );
  }

  static void showRentalType(BuildContext ctx, PropertyFilterModel f) {
    showChoice<String>(
      ctx,
      tr(ctx, 'filterrentaltype', 'Rental Type'),
      f.rentalType,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        (label: tr(ctx, 'rentalbed', 'Bed'), value: 'bed'),
        (label: tr(ctx, 'rentalroom', 'Room'), value: 'room'),
        (label: tr(ctx, 'rentalapartment', 'Apartment'), value: 'apartment'),
      ],
      (v) => apply(
        ctx,
        v == null
            ? f.copyWith(clearRentalType: true)
            : f.copyWith(rentalType: v),
      ),
    );
  }

  static void showLocation(BuildContext ctx, PropertyFilterModel f) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterLocationSheet(
        initialFilter: f,
        onApply: (nf) => apply(ctx, nf),
      ),
    );
  }

  static void showPropertyType(BuildContext ctx, PropertyFilterModel f) {
    showChoice<String>(
      ctx,
      tr(ctx, 'filterpropertytype', 'Property Type'),
      f.propertyType,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        (
          label: tr(ctx, 'propertytypeapartment', 'Apartment'),
          value: 'apartment',
        ),
        (label: tr(ctx, 'propertytypevilla', 'Villa'), value: 'villa'),
        (label: tr(ctx, 'propertytypestudio', 'Studio'), value: 'studio'),
        (
          label: tr(ctx, 'propertytypepenthouse', 'Penthouse'),
          value: 'penthouse',
        ),
        (label: tr(ctx, 'propertytypeduplex', 'Duplex'), value: 'duplex'),
        (label: tr(ctx, 'propertytypechalet', 'Chalet'), value: 'chalet'),
      ],
      (v) => apply(
        ctx,
        v == null
            ? f.copyWith(clearPropertyType: true)
            : f.copyWith(propertyType: v),
      ),
    );
  }

  static void showFurnished(BuildContext ctx, PropertyFilterModel f) {
    showChoice<String>(
      ctx,
      tr(ctx, 'filterfurnished', 'Furnishing'),
      f.isFurnished == null ? null : (f.isFurnished! ? 'yes' : 'no'),
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        (label: tr(ctx, 'filterfurnishedyes', 'Furnished'), value: 'yes'),
        (label: tr(ctx, 'filterfurnishedno', 'Unfurnished'), value: 'no'),
      ],
      (v) {
        if (v == null) {
          apply(ctx, f.copyWith(clearIsFurnished: true));
        } else {
          apply(ctx, f.copyWith(isFurnished: v == 'yes'));
        }
      },
    );
  }

  static void showRooms(BuildContext ctx, PropertyFilterModel f) {
    showChoice<int>(
      ctx,
      tr(ctx, 'filterrooms', 'Rooms'),
      f.minRooms,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        ...[1, 2, 3, 4, 5].map((n) => (label: '$n+', value: n)),
      ],
      (v) => apply(
        ctx,
        v == null ? f.copyWith(clearMinRooms: true) : f.copyWith(minRooms: v),
      ),
    );
  }

  static void showBeds(BuildContext ctx, PropertyFilterModel f) {
    showChoice<int>(
      ctx,
      tr(ctx, 'filterbeds', 'Beds'),
      f.minBeds,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        ...[1, 2, 3, 4, 6].map((n) => (label: '$n+', value: n)),
      ],
      (v) => apply(
        ctx,
        v == null ? f.copyWith(clearMinBeds: true) : f.copyWith(minBeds: v),
      ),
    );
  }

  static void showAudience(BuildContext ctx, PropertyFilterModel f) {
    showChoice<String>(
      ctx,
      tr(ctx, 'filteraudience', 'Tenant Type'),
      f.targetAudience,
      [
        (label: tr(ctx, 'filterall', 'All'), value: null),
        (label: tr(ctx, 'audiencemale', 'Male'), value: 'male'),
        (label: tr(ctx, 'audiencefemale', 'Female'), value: 'female'),
        (label: tr(ctx, 'audiencefamily', 'Families'), value: 'family'),
      ],
      (v) => apply(
        ctx,
        v == null
            ? f.copyWith(clearTargetAudience: true)
            : f.copyWith(targetAudience: v),
      ),
    );
  }

  static void showPrice(BuildContext ctx, PropertyFilterModel f) {
    final isSale = f.listingType == 'sale';
    final opts = isSale
        ? [
            (label: tr(ctx, 'filterall', 'All'), min: null, max: null),
            (
              label: '${tr(ctx, 'filterupto', 'Up to')} ${money(ctx, 500000)}',
              min: null,
              max: 500000.0,
            ),
            (
              label: '${money(ctx, 500000)} - ${money(ctx, 1000000)}',
              min: 500000.0,
              max: 1000000.0,
            ),
            (
              label: '${money(ctx, 1000000)} - ${money(ctx, 2000000)}',
              min: 1000000.0,
              max: 2000000.0,
            ),
            (
              label: '${tr(ctx, 'filterfrom', 'From')} ${money(ctx, 2000000)}',
              min: 2000000.0,
              max: null,
            ),
          ]
        : [
            (label: tr(ctx, 'filterall', 'All'), min: null, max: null),
            (
              label: '${tr(ctx, 'filterupto', 'Up to')} ${money(ctx, 1000)}',
              min: null,
              max: 1000.0,
            ),
            (
              label: '${money(ctx, 1000)} - ${money(ctx, 2000)}',
              min: 1000.0,
              max: 2000.0,
            ),
            (
              label: '${money(ctx, 2000)} - ${money(ctx, 5000)}',
              min: 2000.0,
              max: 5000.0,
            ),
            (
              label: '${money(ctx, 5000)} - ${money(ctx, 10000)}',
              min: 5000.0,
              max: 10000.0,
            ),
            (
              label: '${tr(ctx, 'filterfrom', 'From')} ${money(ctx, 10000)}',
              min: 10000.0,
              max: null,
            ),
          ];
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterChoiceSheet(
        title: tr(ctx, 'filterprice', 'Price'),
        children: opts
            .map(
              (o) => FilterSheetTile(
                label: o.label,
                isSelected: f.minPrice == o.min && f.maxPrice == o.max,
                onTap: () {
                  Navigator.pop(ctx);
                  apply(
                    ctx,
                    f.copyWith(
                      minPrice: o.min,
                      maxPrice: o.max,
                      clearMinPrice: o.min == null,
                      clearMaxPrice: o.max == null,
                    ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
