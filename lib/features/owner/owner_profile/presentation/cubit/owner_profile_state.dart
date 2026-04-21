import 'package:aqar_hub/features/shared/profile/data/models/profile_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OwnerProfileState
//
// File path:
//   lib/features/house_seeker/home/presentation/cubit/owner_profile_state.dart
// ─────────────────────────────────────────────────────────────────────────────

sealed class OwnerProfileState {
  const OwnerProfileState();
}

final class OwnerProfileInitial extends OwnerProfileState {
  const OwnerProfileInitial();
}

final class OwnerProfileLoading extends OwnerProfileState {
  const OwnerProfileLoading();
}

final class OwnerProfileLoaded extends OwnerProfileState {
  /// Parsed profile from the `profiles` table (may be null if row doesn't exist)
  final ProfileModel? profile;

  /// Auth user_metadata — only for Google OAuth users viewing own profile.
  /// Contains: picture / avatar_url / full_name / name / email
  final Map<String, dynamic>? userMeta;

  /// All published properties for this owner
  final List<Map<String, dynamic>> properties;

  const OwnerProfileLoaded({
    this.profile,
    this.userMeta,
    required this.properties,
  });

  // ── Resolved display helpers ───────────────────────────────────────────────

  /// Resolves name from: profile table → Google OAuth meta → [fallback]
  String resolvedName(String fallback) {
    final fromProfile = profile?.fullName.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;

    final metaName =
        (userMeta?['full_name'] as String?)?.trim() ??
        (userMeta?['name'] as String?)?.trim();
    if (metaName != null && metaName.isNotEmpty) return metaName;

    return fallback;
  }

  /// Phone from profiles table
  String? get resolvedPhone {
    final p = profile?.phoneNumber?.trim();
    return (p != null && p.isNotEmpty) ? p : null;
  }

  /// Avatar: profiles table → Google OAuth picture/avatar_url
  String? get resolvedAvatar {
    final fromProfile = profile?.profileImageUrl?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    return (userMeta?['picture'] as String?)?.trim() ??
        (userMeta?['avatar_url'] as String?)?.trim();
  }

  String? get resolvedEmail {
    final fromProfile = profile?.email?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    return (userMeta?['email'] as String?)?.trim();
  }

  String? get city => profile?.city?.trim();
  String? get address => profile?.address?.trim();

  int get apartmentsCount => (profile?.apartmentsCount ?? 0) > 0
      ? profile!.apartmentsCount
      : properties.length;

  String? get memberSince {
    // profiles table has created_at — we don't have it in ProfileModel yet
    // so this is best-effort; will show '—' unless model is extended
    return null;
  }
}

final class OwnerProfileError extends OwnerProfileState {
  final String message;
  const OwnerProfileError(this.message);
}
