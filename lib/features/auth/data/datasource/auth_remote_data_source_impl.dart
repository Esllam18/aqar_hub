import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;
  GoogleSignIn get _google => GoogleSignIn.instance;

  // ── Sign Up ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('signup_failed');
    return UserModel(uid: user.id, email: user.email);
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw Exception('login_failed');

    final profile = await getProfile(user.id);
    return profile ?? UserModel(uid: user.id, email: user.email);
  }

  // ── Google Sign In ─────────────────────────────────────────────────────────
  //
  // google_sign_in v7 removed accessToken from GoogleSignInAuthentication.
  // Supabase's signInWithIdToken only requires idToken — accessToken is optional
  // and has been removed here to fix the compile error.

  @override
  Future<UserModel> signInWithGoogle() async {
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null) throw Exception('err_google_token_null');

    final res = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      // accessToken intentionally omitted — not available in google_sign_in v7
    );
    final user = res.user;
    if (user == null) throw Exception('err_google_login_failed');

    // ── Persist Google profile data into profiles ──────────────────────────
    final email = user.email ?? account.email;
    final meta = user.userMetadata ?? {};
    final avatarUrl = (meta['avatar_url'] as String? ?? '').isNotEmpty
        ? meta['avatar_url'] as String
        : (meta['picture'] as String? ?? '').isNotEmpty
        ? meta['picture'] as String
        : null;
    final firstName = (meta['given_name'] as String?)?.isNotEmpty == true
        ? meta['given_name'] as String
        : (meta['name'] as String? ?? '').isNotEmpty
        ? (meta['name'] as String).split(' ').first
        : null;
    final lastName = (meta['family_name'] as String?)?.isNotEmpty == true
        ? meta['family_name'] as String
        : null;

    final upsertData = <String, dynamic>{'id': user.id};
    if (email.isNotEmpty) upsertData['email'] = email;
    if (avatarUrl != null) upsertData['profile_image_url'] = avatarUrl;
    if (firstName != null && firstName.isNotEmpty) {
      upsertData['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      upsertData['last_name'] = lastName;
    }
    await _supabase
        .from('profiles')
        .upsert(upsertData, onConflict: 'id', ignoreDuplicates: false);

    final profile = await getProfile(user.id);
    return profile ?? UserModel(uid: user.id, email: email);
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordReset(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ── Role & Profile ─────────────────────────────────────────────────────────

  @override
  Future<void> saveRole(String uid, String role) async {
    await _supabase.from('profiles').upsert({'id': uid, 'role': role});
  }

  @override
  Future<void> saveProfile(UserModel user) async {
    await _supabase.from('profiles').upsert(user.toMap());
  }

  @override
  Future<UserModel?> getProfile(String uid) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {
      // Google sign-out is best-effort — never block logout
    }
    await _supabase.auth.signOut();
  }

  // ── Current User ──────────────────────────────────────────────────────────

  @override
  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return UserModel(uid: user.id, email: user.email);
  }
}
