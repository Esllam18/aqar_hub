// lib/features/owner/add_property/data/models/add_property_form_model.dart
//
// KEY CHANGE: toInsertMap() now calls _safeSlug() on every slug value before
// writing to the DB.  This permanently prevents hyphens from being stored,
// regardless of what the picker hands back.

import 'dart:io';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';

enum AiConfidence { low, medium, high }

class AiPriceResult {
  final double suggestedPrice;
  final double? minPrice;
  final double? maxPrice;
  final String priceLabel;
  final AiConfidence confidence;
  final String explanation;

  const AiPriceResult({
    required this.suggestedPrice,
    this.minPrice,
    this.maxPrice,
    required this.priceLabel,
    required this.confidence,
    required this.explanation,
  });

  Map<String, dynamic> toMap() => {
    'ai_suggested_price': suggestedPrice,
    'ai_min_price': minPrice,
    'ai_max_price': maxPrice,
    'ai_price_label': priceLabel,
    'ai_confidence': confidence.name,
    'ai_explanation': explanation,
  };
}

class RentalOptionDraft {
  final String type;
  final double price;
  final int totalQuantity;
  final int availableQuantity;

  const RentalOptionDraft({
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
  });

  Map<String, dynamic> toMap(String propertyId) => {
    'property_id': propertyId,
    'type': type,
    'price': price,
    'total_quantity': totalQuantity,
    'available_quantity': availableQuantity,
  };

  RentalOptionDraft copyWith({
    String? type,
    double? price,
    int? totalQuantity,
    int? availableQuantity,
  }) => RentalOptionDraft(
    type: type ?? this.type,
    price: price ?? this.price,
    totalQuantity: totalQuantity ?? this.totalQuantity,
    availableQuantity: availableQuantity ?? this.availableQuantity,
  );
}

class AddPropertyFormModel {
  final String title;

  /// Canonical slug — underscores only, ALWAYS stored in DB.
  final String governorateSlug;

  /// Canonical slug — underscores only, ALWAYS stored in DB.
  final String citySlug;

  /// Canonical slug — underscores only, ALWAYS stored in DB.
  final String areaSlug;

  final String address;
  final String locationLink;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final int? totalRooms;
  final int? totalBeds;
  final int? bathrooms;
  final double? areaM2;
  final bool isFurnished;
  final List<String> amenities;
  final String listingType;
  final String targetAudience;
  final double? basePrice;
  final List<RentalOptionDraft> rentalOptions;
  final List<File> localImages;
  final File? localVideo;
  final List<String> uploadedUrls;
  final String description;
  final AiPriceResult? aiPriceResult;

  const AddPropertyFormModel({
    this.title = '',
    this.governorateSlug = '',
    this.citySlug = '',
    this.areaSlug = '',
    this.address = '',
    this.locationLink = '',
    this.latitude,
    this.longitude,
    this.propertyType = 'apartment',
    this.totalRooms,
    this.totalBeds,
    this.bathrooms,
    this.areaM2,
    this.isFurnished = false,
    this.amenities = const [],
    this.listingType = 'rent',
    this.targetAudience = 'all',
    this.basePrice,
    this.rentalOptions = const [],
    this.localImages = const [],
    this.localVideo,
    this.uploadedUrls = const [],
    this.description = '',
    this.aiPriceResult,
  });

  bool get hasLocation => governorateSlug.isNotEmpty;
  bool get isRent => listingType == 'rent';
  bool get hasLocationLink =>
      locationLink.isNotEmpty &&
      (locationLink.startsWith('http://') ||
          locationLink.startsWith('https://'));

  String get locationKey {
    if (areaSlug.isNotEmpty) return '$governorateSlug/$citySlug/$areaSlug';
    if (citySlug.isNotEmpty) return '$governorateSlug/$citySlug';
    return governorateSlug;
  }

  // ── Slug sanitizer ────────────────────────────────────────────────────────
  // Converts hyphens to underscores so DB always receives consistent slugs.
  // This is a last-resort guard; ideally the Dart location files already use
  // underscores everywhere.
  static String _safeSlug(String slug) => slug.replaceAll('-', '_');

  // ── copyWith ──────────────────────────────────────────────────────────────

  AddPropertyFormModel copyWith({
    String? title,
    String? governorateSlug,
    String? citySlug,
    String? areaSlug,
    String? address,
    String? locationLink,
    double? latitude,
    double? longitude,
    bool clearLatLng = false,
    String? propertyType,
    int? totalRooms,
    int? totalBeds,
    int? bathrooms,
    double? areaM2,
    bool? isFurnished,
    List<String>? amenities,
    String? listingType,
    String? targetAudience,
    double? basePrice,
    bool clearBasePrice = false,
    List<RentalOptionDraft>? rentalOptions,
    List<File>? localImages,
    File? localVideo,
    bool clearLocalVideo = false,
    List<String>? uploadedUrls,
    String? description,
    AiPriceResult? aiPriceResult,
  }) => AddPropertyFormModel(
    title: title ?? this.title,
    // Sanitize slugs at copyWith time so state is always clean
    governorateSlug: governorateSlug != null
        ? _safeSlug(governorateSlug)
        : this.governorateSlug,
    citySlug: citySlug != null ? _safeSlug(citySlug) : this.citySlug,
    areaSlug: areaSlug != null ? _safeSlug(areaSlug) : this.areaSlug,
    address: address ?? this.address,
    locationLink: locationLink ?? this.locationLink,
    latitude: clearLatLng ? null : (latitude ?? this.latitude),
    longitude: clearLatLng ? null : (longitude ?? this.longitude),
    propertyType: propertyType ?? this.propertyType,
    totalRooms: totalRooms ?? this.totalRooms,
    totalBeds: totalBeds ?? this.totalBeds,
    bathrooms: bathrooms ?? this.bathrooms,
    areaM2: areaM2 ?? this.areaM2,
    isFurnished: isFurnished ?? this.isFurnished,
    amenities: amenities ?? this.amenities,
    listingType: listingType ?? this.listingType,
    targetAudience: targetAudience ?? this.targetAudience,
    basePrice: clearBasePrice ? null : (basePrice ?? this.basePrice),
    rentalOptions: rentalOptions ?? this.rentalOptions,
    localImages: localImages ?? this.localImages,
    localVideo: clearLocalVideo ? null : (localVideo ?? this.localVideo),
    uploadedUrls: uploadedUrls ?? this.uploadedUrls,
    description: description ?? this.description,
    aiPriceResult: aiPriceResult ?? this.aiPriceResult,
  );

  // ── DB insert map ─────────────────────────────────────────────────────────

  Map<String, dynamic> toInsertMap({
    required String ownerId,
    required List<String> imageUrls,
    String? videoUrl,
  }) {
    const validLabels = {'normal', 'verified', 'offer'};
    final rawLabel = aiPriceResult?.priceLabel ?? 'normal';
    final priceLabel = validLabels.contains(rawLabel) ? rawLabel : 'verified';

    // Sanitize at write time — belt-and-suspenders
    final govSlug = _safeSlug(governorateSlug);
    final ctSlug = _safeSlug(citySlug);
    final arSlug = _safeSlug(areaSlug);

    final locationPath = EgyptLocations.buildLocationPath(
      governorateSlug: govSlug,
      citySlug: ctSlug.isEmpty ? null : ctSlug,
      areaSlug: arSlug.isEmpty ? null : arSlug,
    );

    final cityColumnValue = ctSlug.isNotEmpty ? ctSlug : govSlug;

    return {
      'owner_id': ownerId,
      'title': title.trim(),
      'description': description.trim(),
      'address': address.trim(),

      // ── Location slugs — always underscores, never hyphens, never display names
      'governorate_slug': govSlug.isEmpty ? null : govSlug,
      'city_slug': ctSlug.isEmpty ? null : ctSlug,
      'area_slug': arSlug.isEmpty ? null : arSlug,
      'city': cityColumnValue,
      'location_path': locationPath.isEmpty ? null : locationPath,

      'total_rooms': totalRooms,
      'total_beds': totalBeds,
      'bathrooms': bathrooms,
      'area_m2': areaM2,
      'is_furnished': isFurnished,
      'listing_type': listingType,
      'target_audience': targetAudience,
      'price_label': priceLabel,
      'property_type': propertyType,
      'is_rented': false,
      'base_price': basePrice,
      'image_urls': imageUrls,
      if (amenities.isNotEmpty) 'amenities': amenities,
      if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
      if (locationLink.isNotEmpty && hasLocationLink)
        'location_link': locationLink,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (aiPriceResult != null) ...aiPriceResult!.toMap(),
    };
  }
}
