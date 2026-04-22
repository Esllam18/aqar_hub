class ProfileModel {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? role;
  final String? nationalId;
  final String? profileImageUrl;
  final String? address;
  final String? dateOfBirth;
  final int favoritesCount;
  final int apartmentsCount;
  // ── NEW ──────────────────────────────────────────────────────────────────
  final DateTime? createdAt;

  const ProfileModel({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    this.role,
    this.nationalId,
    this.profileImageUrl,
    this.address,
    this.dateOfBirth,
    this.favoritesCount = 0,
    this.apartmentsCount = 0,
    this.createdAt, // ── NEW
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String? get avatarUrl => profileImageUrl;

  factory ProfileModel.fromMap(Map<String, dynamic> m) => ProfileModel(
    uid: m['id'] as String,
    email: m['email'] as String?,
    firstName: m['first_name'] as String?,
    lastName: m['last_name'] as String?,
    phoneNumber: m['phone_number'] as String?,
    city: m['city'] as String?,
    role: m['role'] as String?,
    nationalId: m['national_id'] as String?,
    profileImageUrl: m['profile_image_url'] as String?,
    address: m['address'] as String?,
    dateOfBirth: m['date_of_birth'] as String?,
    favoritesCount: (m['favorites_count'] as int?) ?? 0,
    apartmentsCount: (m['apartments_count'] as int?) ?? 0,
    // ── NEW: parse created_at from DB ───────────────────────────────────
    createdAt: m['created_at'] != null
        ? DateTime.tryParse(m['created_at'] as String)
        : null,
  );

  factory ProfileModel.fromJson(Map<String, dynamic> m) =>
      ProfileModel.fromMap(m);

  Map<String, dynamic> toMap() => {
    'id': uid,
    'email': email,
    'role': role,
    'favorites_count': favoritesCount,
    'apartments_count': apartmentsCount,
    if (firstName != null) 'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
    if (phoneNumber != null) 'phone_number': phoneNumber,
    if (city != null) 'city': city,
    if (nationalId != null) 'national_id': nationalId,
    if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    if (address != null) 'address': address,
    if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
    // Note: created_at is managed by the DB — never overwrite it on update.
  };

  Map<String, dynamic> toJson() => toMap();

  ProfileModel copyWith({
    String? email,
    String? role,
    int? favoritesCount,
    int? apartmentsCount,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? city,
    String? nationalId,
    String? profileImageUrl,
    String? address,
    String? dateOfBirth,
    DateTime? createdAt, // ── NEW
  }) => ProfileModel(
    uid: uid,
    email: email ?? this.email,
    role: role ?? this.role,
    favoritesCount: favoritesCount ?? this.favoritesCount,
    apartmentsCount: apartmentsCount ?? this.apartmentsCount,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    city: city ?? this.city,
    nationalId: nationalId ?? this.nationalId,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    address: address ?? this.address,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    createdAt: createdAt ?? this.createdAt, // ── NEW
  );
}
