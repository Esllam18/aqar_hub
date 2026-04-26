import 'rental_option_model.dart';

class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final int? totalRooms;
  final int? totalBeds;
  final int? bathrooms;
  final double? areaM2;
  final bool isFurnished;
  final String listingType;
  final String targetAudience;
  final String priceLabel;
  final bool isRented;
  final double? basePrice;
  final List<String> imageUrls;
  final List<String> amenities;
  final List<RentalOptionModel> rentalOptions;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerAvatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String propertyType;
  final String? videoUrl;
  final String? governorateSlug;
  final String? citySlug;
  final String? areaSlug;
  final String? locationPath;
  final String locationLink;

  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.totalRooms,
    this.totalBeds,
    this.bathrooms,
    this.areaM2,
    this.isFurnished = false,
    required this.listingType,
    this.targetAudience = 'all',
    this.priceLabel = 'normal',
    this.isRented = false,
    this.basePrice,
    this.imageUrls = const [],
    this.amenities = const [],
    this.rentalOptions = const [],
    this.ownerName,
    this.ownerPhone,
    this.ownerAvatar,
    required this.createdAt,
    this.updatedAt,
    this.propertyType = 'apartment',
    this.videoUrl,
    this.governorateSlug,
    this.citySlug,
    this.areaSlug,
    this.locationPath,
    this.locationLink = '',
  });

  String? get firstImage => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get isForSale => listingType == 'sale';
  bool get isVerified => priceLabel == 'verified';
  bool get isOffer => priceLabel == 'offer';

  double? get displayPrice {
    if (basePrice != null) return basePrice;
    if (rentalOptions.isEmpty) return null;
    return rentalOptions.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  bool get hasAvailabilityAlert =>
      rentalOptions.any((e) => e.isFullyBooked || e.isLimited);

  int get fullyBookedOptionsCount =>
      rentalOptions.where((e) => e.isFullyBooked).length;

  int get limitedOptionsCount => rentalOptions.where((e) => e.isLimited).length;

  PropertyModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    int? totalRooms,
    int? totalBeds,
    int? bathrooms,
    double? areaM2,
    bool? isFurnished,
    String? listingType,
    String? targetAudience,
    String? priceLabel,
    bool? isRented,
    double? basePrice,
    List<String>? imageUrls,
    List<String>? amenities,
    List<RentalOptionModel>? rentalOptions,
    String? ownerName,
    String? ownerPhone,
    String? ownerAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? propertyType,
    String? videoUrl,
    String? governorateSlug,
    String? citySlug,
    String? areaSlug,
    String? locationPath,
    String? locationLink,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
      bathrooms: bathrooms ?? this.bathrooms,
      areaM2: areaM2 ?? this.areaM2,
      isFurnished: isFurnished ?? this.isFurnished,
      listingType: listingType ?? this.listingType,
      targetAudience: targetAudience ?? this.targetAudience,
      priceLabel: priceLabel ?? this.priceLabel,
      isRented: isRented ?? this.isRented,
      basePrice: basePrice ?? this.basePrice,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      rentalOptions: rentalOptions ?? this.rentalOptions,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      propertyType: propertyType ?? this.propertyType,
      videoUrl: videoUrl ?? this.videoUrl,
      governorateSlug: governorateSlug ?? this.governorateSlug,
      citySlug: citySlug ?? this.citySlug,
      areaSlug: areaSlug ?? this.areaSlug,
      locationPath: locationPath ?? this.locationPath,
      locationLink: locationLink ?? this.locationLink,
    );
  }

  static String _readString(
    Map<String, dynamic> m,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = m[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return fallback;
  }

  static bool _readBool(
    Map<String, dynamic> m,
    List<String> keys, [
    bool fallback = false,
  ]) {
    for (final key in keys) {
      final value = m[key];
      if (value is bool) return value;
      if (value is int) return value == 1;
    }
    return fallback;
  }

  static int? _readInt(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final value = m[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final value = m[key];
      if (value is num) return value.toDouble();
    }
    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final value = m[key];
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
    }
    return null;
  }

  static List<String> _readStringList(
    Map<String, dynamic> m,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = m[key];
      if (value is List) {
        return List<String>.from(value);
      }
    }
    return const [];
  }

  /// Serialise to a plain Map so PropertyModel can be stored in AppPrefs cache.
  /// Keys match the snake_case column names that fromMap() accepts.
  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'title': title,
    'description': description,
    'city': city,
    'address': address,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (totalRooms != null) 'total_rooms': totalRooms,
    if (totalBeds != null) 'total_beds': totalBeds,
    if (bathrooms != null) 'bathrooms': bathrooms,
    if (areaM2 != null) 'area_m2': areaM2,
    'is_furnished': isFurnished,
    'listing_type': listingType,
    'target_audience': targetAudience,
    'price_label': priceLabel,
    'is_rented': isRented,
    if (basePrice != null) 'base_price': basePrice,
    'image_urls': imageUrls,
    'amenities': amenities,
    if (ownerName != null) 'owner_name': ownerName,
    if (ownerPhone != null) 'owner_phone': ownerPhone,
    if (ownerAvatar != null) 'owner_avatar': ownerAvatar,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    'property_type': propertyType,
    if (videoUrl != null) 'video_url': videoUrl,
    if (governorateSlug != null) 'governorate_slug': governorateSlug,
    if (citySlug != null) 'city_slug': citySlug,
    if (areaSlug != null) 'area_slug': areaSlug,
    if (locationPath != null) 'location_path': locationPath,
  };

  factory PropertyModel.fromMap(
    Map<String, dynamic> m, {
    List<RentalOptionModel> options = const [],
  }) {
    return PropertyModel(
      id: _readString(m, ['id']),
      ownerId: _readString(m, ['ownerid', 'owner_id']),
      title: _readString(m, ['title']),
      description: _readString(m, ['description']),
      city: _readString(m, ['city']),
      address: _readString(m, ['address']),
      latitude: _readDouble(m, ['latitude']),
      longitude: _readDouble(m, ['longitude']),
      totalRooms: _readInt(m, ['totalrooms', 'total_rooms']),
      totalBeds: _readInt(m, ['totalbeds', 'total_beds']),
      bathrooms: _readInt(m, ['bathrooms']),
      areaM2: _readDouble(m, ['aream2', 'area_m2']),
      isFurnished: _readBool(m, ['isfurnished', 'is_furnished']),
      listingType: _readString(m, ['listingtype', 'listing_type'], 'rent'),
      targetAudience: _readString(m, [
        'targetaudience',
        'target_audience',
      ], 'all'),
      priceLabel: _readString(m, ['pricelabel', 'price_label'], 'normal'),
      isRented: _readBool(m, ['isrented', 'is_rented']),
      basePrice: _readDouble(m, ['baseprice', 'base_price']),
      imageUrls: _readStringList(m, ['imageurls', 'image_urls']),
      amenities: _readStringList(m, ['amenities']),
      rentalOptions: options,
      ownerName: _readString(m, ['ownername', 'owner_name']),
      ownerPhone: _readString(m, ['ownerphone', 'owner_phone']),
      ownerAvatar: _readString(m, ['owneravatar', 'owner_avatar']),
      createdAt: _readDate(m, ['createdat', 'created_at']) ?? DateTime.now(),
      updatedAt: _readDate(m, ['updatedat', 'updated_at']),
      propertyType: _readString(m, [
        'propertytype',
        'property_type',
      ], 'apartment'),
      videoUrl: _readString(m, ['videourl', 'video_url']),
      governorateSlug: _readString(m, ['governorateslug', 'governorate_slug']),
      citySlug: _readString(m, ['cityslug', 'city_slug']),
      areaSlug: _readString(m, ['areaslug', 'area_slug']),
      locationPath: _readString(m, ['locationpath', 'location_path']),
      locationLink: _readString(m, ['locationlink', 'location_link']),
    );
  }
}
