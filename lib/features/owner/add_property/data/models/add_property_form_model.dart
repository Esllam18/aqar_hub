import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// AI Price Result — returned by the AI model (mocked until connected)
// ─────────────────────────────────────────────────────────────────────────────

enum AiConfidence { low, medium, high }

class AiPriceResult {
  final double suggestedPrice;
  final double? minPrice;
  final double? maxPrice;
  final String priceLabel; // 'normal' | 'verified' | 'offer' | 'featured'
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

// ─────────────────────────────────────────────────────────────────────────────
// Draft rental option (before DB insert — no id yet)
// ─────────────────────────────────────────────────────────────────────────────

class RentalOptionDraft {
  final String type; // 'bed' | 'room' | 'apartment'
  final double price; // price per unit (per bed / per room / per apartment)
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

// ─────────────────────────────────────────────────────────────────────────────
// Full form state for the Add Property wizard
// ─────────────────────────────────────────────────────────────────────────────

class AddPropertyFormModel {
  // Step 0 — Basic Info + Location
  final String title;
  final String governorateSlug; // mandatory
  final String citySlug; // mandatory if governorate has cities
  final String address; // optional free-text
  final String locationLink; // optional Google Maps URL

  // Step 1 — Property Type
  final String
  propertyType; // apartment | villa | studio | penthouse | duplex | chalet

  // Step 2 — Specs
  final int? totalRooms;
  final int? totalBeds;
  final int? bathrooms;
  final double? areaM2;
  final bool isFurnished;

  // Step 3 — Amenities / Features
  final List<String> amenities;

  // Step 4 — Listing Type
  final String listingType; // rent | sale
  final String targetAudience; // all | male | female | family

  // Step 5 — Pricing
  final double? basePrice;
  final List<RentalOptionDraft> rentalOptions;

  // Step 6 — Media
  final List<File> localImages;
  final File? localVideo; // optional video file
  final List<String> uploadedUrls; // set after upload

  // Step 7 — Description + AI  (was Step 6)
  final String description;
  final AiPriceResult? aiPriceResult; // set after AI check

  const AddPropertyFormModel({
    this.title = '',
    this.governorateSlug = '',
    this.citySlug = '',
    this.address = '',
    this.locationLink = '',
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

  /// City display name helper — use EgyptLocations.findCity for full label
  String get locationKey =>
      citySlug.isNotEmpty ? '$governorateSlug/$citySlug' : governorateSlug;

  AddPropertyFormModel copyWith({
    String? title,
    String? governorateSlug,
    String? citySlug,
    String? address,
    String? locationLink,
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
    governorateSlug: governorateSlug ?? this.governorateSlug,
    citySlug: citySlug ?? this.citySlug,
    address: address ?? this.address,
    locationLink: locationLink ?? this.locationLink,
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

  /// Build the DB insert map.
  Map<String, dynamic> toInsertMap({
    required String ownerId,
    required List<String> imageUrls,
    String? videoUrl,
  }) {
    // DB constraint: price_label only accepts normal | verified | offer
    // 'featured' is a UI concept only — map it to 'verified' for storage
    const validLabels = {'normal', 'verified', 'offer'};
    final rawLabel = aiPriceResult?.priceLabel ?? 'normal';
    final priceLabel = validLabels.contains(rawLabel) ? rawLabel : 'verified';

    return {
      // Snake_case column names (original DB schema)
      'owner_id': ownerId,
      'title': title.trim(),
      'description': description.trim(),
      'address': address.trim(),
      'city': citySlug.isNotEmpty ? citySlug : governorateSlug,
      'governorate_slug': governorateSlug.isEmpty ? null : governorateSlug,
      'city_slug': citySlug.isEmpty ? null : citySlug,
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
      if (videoUrl != null && videoUrl.isNotEmpty) 'videourl': videoUrl,
      if (locationLink.isNotEmpty && hasLocationLink)
        'location_link': locationLink,
      // AI fields
      if (aiPriceResult != null) ...aiPriceResult!.toMap(),
    };
  }
}
