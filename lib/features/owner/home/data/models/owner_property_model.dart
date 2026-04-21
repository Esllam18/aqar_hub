import 'package:aqar_hub/features/owner/home/data/models/property_alert_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';

class OwnerPropertyModel {
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
  final String? videoUrl;
  final String propertyType;
  final String? governorateSlug;
  final String? citySlug;
  final String? areaSlug;
  final String? locationPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RentalOptionModel> rentalOptions;

  const OwnerPropertyModel({
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
    required this.isFurnished,
    required this.listingType,
    required this.targetAudience,
    required this.priceLabel,
    required this.isRented,
    this.basePrice,
    required this.imageUrls,
    this.videoUrl,
    required this.propertyType,
    this.governorateSlug,
    this.citySlug,
    this.areaSlug,
    this.locationPath,
    required this.createdAt,
    this.updatedAt,
    required this.rentalOptions,
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

  List<PropertyAlertModel> get alerts {
    final items = <PropertyAlertModel>[];

    if (isRented) {
      items.add(
        const PropertyAlertModel(
          code: 'rented',
          severity: PropertyAlertSeverity.error,
        ),
      );
    }

    if (isVerified) {
      items.add(
        const PropertyAlertModel(
          code: 'verified',
          severity: PropertyAlertSeverity.info,
        ),
      );
    }

    if (isOffer) {
      items.add(
        const PropertyAlertModel(
          code: 'offer',
          severity: PropertyAlertSeverity.warning,
        ),
      );
    }

    for (final option in rentalOptions) {
      if (option.isFullyBooked) {
        items.add(
          PropertyAlertModel(
            code: 'fullyBooked',
            severity: PropertyAlertSeverity.error,
            rentalType: option.type,
          ),
        );
      } else if (option.isLimited) {
        items.add(
          PropertyAlertModel(
            code: 'limited',
            severity: PropertyAlertSeverity.warning,
            rentalType: option.type,
            remaining: option.availableQuantity,
          ),
        );
      }
    }

    if (items.isEmpty) {
      items.add(
        const PropertyAlertModel(
          code: 'available',
          severity: PropertyAlertSeverity.success,
        ),
      );
    }

    return items;
  }

  OwnerPropertyModel copyWith({
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
    String? videoUrl,
    String? propertyType,
    String? governorateSlug,
    String? citySlug,
    String? areaSlug,
    String? locationPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RentalOptionModel>? rentalOptions,
  }) {
    return OwnerPropertyModel(
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
      videoUrl: videoUrl ?? this.videoUrl,
      propertyType: propertyType ?? this.propertyType,
      governorateSlug: governorateSlug ?? this.governorateSlug,
      citySlug: citySlug ?? this.citySlug,
      areaSlug: areaSlug ?? this.areaSlug,
      locationPath: locationPath ?? this.locationPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rentalOptions: rentalOptions ?? this.rentalOptions,
    );
  }

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
    if (videoUrl != null) 'video_url': videoUrl,
    'property_type': propertyType,
    if (governorateSlug != null) 'governorate_slug': governorateSlug,
    if (citySlug != null) 'city_slug': citySlug,
    if (areaSlug != null) 'area_slug': areaSlug,
    if (locationPath != null) 'location_path': locationPath,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    'rental_options': rentalOptions.map((r) => r.toMap()).toList(),
  };

  // OwnerPropertyModel.fromMap (owner side) – make it tolerant like seeker model
  factory OwnerPropertyModel.fromMap(
    Map<String, dynamic> map,
    List<RentalOptionModel> options,
  ) {
    String readString(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final value = map[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return fallback;
    }

    bool readBool(List<String> keys, [bool fallback = false]) {
      for (final key in keys) {
        final value = map[key];
        if (value is bool) return value;
        if (value is int) return value == 1;
      }
      return fallback;
    }

    int? readInt(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
      }
      return null;
    }

    double? readDouble(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is num) return value.toDouble();
      }
      return null;
    }

    DateTime? readDate(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String && value.isNotEmpty) {
          return DateTime.tryParse(value);
        }
      }
      return null;
    }

    List<String> readList(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
      }
      return const [];
    }

    return OwnerPropertyModel(
      id: readString(['id']),
      ownerId: readString(['owner_id', 'ownerid']),
      title: readString(['title']),
      description: readString(['description']),
      city: readString(['city']),
      address: readString(['address']),
      latitude: readDouble(['latitude']),
      longitude: readDouble(['longitude']),
      totalRooms: readInt(['total_rooms', 'totalrooms']),
      totalBeds: readInt(['total_beds', 'totalbeds']),
      bathrooms: readInt(['bathrooms']),
      areaM2: readDouble(['area_m2', 'aream2']),
      isFurnished: readBool(['is_furnished', 'isfurnished']),
      listingType: readString(['listing_type', 'listingtype'], 'rent'),
      targetAudience: readString(['target_audience', 'targetaudience'], 'all'),
      priceLabel: readString(['price_label', 'pricelabel'], 'normal'),
      isRented: readBool(['is_rented', 'isrented']),
      basePrice: readDouble(['base_price', 'baseprice']),
      imageUrls: readList(['image_urls', 'imageurls']),
      videoUrl: readString(['video_url', 'videourl']),
      propertyType: readString(['property_type', 'propertytype'], 'apartment'),
      governorateSlug: readString([
        'governorate_slug',
        'governateslug',
        'governorateslug',
      ]),
      citySlug: readString(['city_slug', 'cityslug']),
      areaSlug: readString(['area_slug', 'areaslug']),
      locationPath: readString(['location_path', 'locationpath']),
      createdAt: readDate(['created_at', 'createdat']) ?? DateTime.now(),
      updatedAt: readDate(['updated_at', 'updatedat']),
      rentalOptions: options,
    );
  }
}
