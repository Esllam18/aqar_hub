class UserModel {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? role;

  // ── Real-Estate extras ─────────────────────────────────────────────────────
  final String? nationalId;
  final String? profileImageUrl;
  final String? address;
  final String? dateOfBirth;

  const UserModel({
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
  });

  // ── From Supabase profiles row ─────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] as String,
      email: map['email'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      phoneNumber: map['phone_number'] as String?,
      city: map['city'] as String?,
      role: map['role'] as String?,
      nationalId: map['national_id'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
      address: map['address'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
    );
  }

  // ── To Map for upsert ──────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (city != null) 'city': city,
      if (role != null) 'role': role,
      if (nationalId != null) 'national_id': nationalId,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
    };
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? city,
    String? role,
    String? nationalId,
    String? profileImageUrl,
    String? address,
    String? dateOfBirth,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      role: role ?? this.role,
      nationalId: nationalId ?? this.nationalId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
