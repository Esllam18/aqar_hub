class PropertyFilterModel {
  final String? listingType;
  final String? governorateSlug;
  final String? citySlug;
  final String? areaSlug;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final bool? isFurnished;
  final int? minRooms;
  final int? minBeds;
  final String? targetAudience;
  final String? rentalType;

  const PropertyFilterModel({
    this.listingType,
    this.governorateSlug,
    this.citySlug,
    this.areaSlug,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.isFurnished,
    this.minRooms,
    this.minBeds,
    this.targetAudience,
    this.rentalType,
  });

  const PropertyFilterModel.empty()
    : listingType = null,
      governorateSlug = null,
      citySlug = null,
      areaSlug = null,
      propertyType = null,
      minPrice = null,
      maxPrice = null,
      isFurnished = null,
      minRooms = null,
      minBeds = null,
      targetAudience = null,
      rentalType = null;

  bool get hasAnyFilter =>
      listingType != null ||
      governorateSlug != null ||
      citySlug != null ||
      areaSlug != null ||
      propertyType != null ||
      minPrice != null ||
      maxPrice != null ||
      isFurnished != null ||
      minRooms != null ||
      minBeds != null ||
      targetAudience != null ||
      rentalType != null;

  int get activeCount => [
    listingType,
    governorateSlug,
    citySlug,
    areaSlug,
    propertyType,
    minPrice,
    maxPrice,
    isFurnished,
    minRooms,
    minBeds,
    targetAudience,
    rentalType,
  ].where((e) => e != null).length;

  PropertyFilterModel copyWith({
    String? listingType,
    String? governorateSlug,
    String? citySlug,
    String? areaSlug,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    bool? isFurnished,
    int? minRooms,
    int? minBeds,
    String? targetAudience,
    String? rentalType,
    bool clearListingType = false,
    bool clearGovernorate = false,
    bool clearCity = false,
    bool clearArea = false,
    bool clearPropertyType = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearIsFurnished = false,
    bool clearMinRooms = false,
    bool clearMinBeds = false,
    bool clearTargetAudience = false,
    bool clearRentalType = false,
  }) {
    return PropertyFilterModel(
      listingType: clearListingType ? null : listingType ?? this.listingType,
      governorateSlug: clearGovernorate
          ? null
          : governorateSlug ?? this.governorateSlug,
      citySlug: clearCity ? null : citySlug ?? this.citySlug,
      areaSlug: clearArea ? null : areaSlug ?? this.areaSlug,
      propertyType: clearPropertyType
          ? null
          : propertyType ?? this.propertyType,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      isFurnished: clearIsFurnished ? null : isFurnished ?? this.isFurnished,
      minRooms: clearMinRooms ? null : minRooms ?? this.minRooms,
      minBeds: clearMinBeds ? null : minBeds ?? this.minBeds,
      targetAudience: clearTargetAudience
          ? null
          : targetAudience ?? this.targetAudience,
      rentalType: clearRentalType ? null : rentalType ?? this.rentalType,
    );
  }
}
