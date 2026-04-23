import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/features/auth/data/models/user_model.dart';
import 'package:aqar_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(const AuthInitial());

  // ── Safe emit — never emits on a closed cubit ──────────────────────────────
  void _emit(AuthState state) {
    if (!isClosed) emit(state);
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  Future<void> signUpWithEmail(String email, String password) async {
    _emit(const AuthLoading());
    try {
      final user = await _repo.signUpWithEmail(email, password);
      await AppPrefs.saveUserId(user.uid);
      await AppPrefs.setNeedsProfile(true);
      await AppPrefs.setLoggedIn(false);
      _emit(AuthNeedsRoleSelection(user));
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    _emit(const AuthLoading());
    try {
      final user = await _repo.signInWithEmail(email, password);
      await _handleSignedInUser(user);
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Google ─────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _emit(const AuthLoading());
    try {
      final user = await _repo.signInWithGoogle();
      await _handleSignedInUser(user);
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Role ───────────────────────────────────────────────────────────────────

  Future<void> updateRole(String uid, String role) async {
    final s = state;
    final currentUser = (s is AuthNeedsRoleSelection)
        ? s.user
        : (s is AuthNeedsProfileCompletion)
        ? s.user
        : UserModel(uid: uid);

    _emit(const AuthLoading());
    try {
      await _repo.saveRole(uid, role);
      await AppPrefs.saveUserRole(role);
      _emit(AuthNeedsProfileCompletion(currentUser.copyWith(role: role)));
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Complete Profile ───────────────────────────────────────────────────────

  Future<void> completeProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String city,
    required String role,
    String? nationalId,
    String? address,
    String? dateOfBirth,
  }) async {
    _emit(const AuthLoading());
    try {
      final user = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        city: city,
        role: role,
        nationalId: nationalId,
        address: address,
        dateOfBirth: dateOfBirth,
      );
      await _repo.saveProfile(user);
      await AppPrefs.setLoggedIn(true);
      await AppPrefs.setNeedsProfile(false);
      await AppPrefs.saveUserId(uid);
      await AppPrefs.saveUserRole(role);
      _emit(AuthSuccess(user));
    } catch (e) {
      debugPrint('══ completeProfile ERROR ══ $e');
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Skip Profile ───────────────────────────────────────────────────────────

  Future<void> skipProfile(String uid, String role) async {
    await AppPrefs.setLoggedIn(true);
    await AppPrefs.setNeedsProfile(true);
    await AppPrefs.saveUserId(uid);
    await AppPrefs.saveUserRole(role);
    _emit(AuthSuccess(UserModel(uid: uid, role: role)));
  }

  // ── Forgot Password ────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    _emit(const AuthLoading());
    try {
      await _repo.sendPasswordReset(email);
      _emit(const AuthPasswordResetSent());
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _emit(const AuthLoading());
    try {
      await _repo.updatePassword(newPassword);
      _emit(const AuthPasswordUpdated());
    } catch (e) {
      _emit(AuthError(_mapError(e)));
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    // Remove FCM token from DB first — prevents push notifications
    // from being delivered after logout.
    try {
      await FcmService.instance.removeToken();
    } catch (_) {
      // Non-fatal — token cleanup is best-effort
    }
    try {
      await _repo.signOut();
    } catch (_) {
      // best-effort
    } finally {
      await AppPrefs.clear(); // always runs
    }
    _emit(const AuthInitial());
  }
  // ── Guest ──────────────────────────────────────────────────────────────────

  void continueAsGuest() => _emit(const AuthGuestMode());

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _handleSignedInUser(UserModel user) async {
    final profile = await _repo.getProfile(user.uid);

    if (profile == null || profile.role == null || profile.role!.isEmpty) {
      _emit(AuthNeedsRoleSelection(user));
      return;
    }
    if (profile.firstName == null || profile.firstName!.trim().isEmpty) {
      await AppPrefs.setLoggedIn(true);
      await AppPrefs.saveUserId(user.uid);
      await AppPrefs.saveUserRole(profile.role!);
      await AppPrefs.setNeedsProfile(true);
      await FcmService.instance.registerTokenForCurrentUser();
      _emit(AuthNeedsProfileCompletion(profile));
      return;
    }
    await AppPrefs.setLoggedIn(true);
    await AppPrefs.saveUserId(user.uid);
    await AppPrefs.saveUserRole(profile.role!);
    await AppPrefs.setNeedsProfile(false);
    // Register FCM token now that the user is authenticated —
    // this is the correct time because currentUser is guaranteed non-null
    await FcmService.instance.registerTokenForCurrentUser();
    _emit(AuthSuccess(profile));
  }

  // ── Error Mapper ───────────────────────────────────────────────────────────

  String _mapError(Object e) {
    debugPrint('══ AUTH ERROR ══ $e');

    final msg = e.toString().toLowerCase();

    if (msg.contains('invalid login') ||
        msg.contains('invalid_credentials') ||
        msg.contains('email not confirmed')) {
      return 'err_invalid_credentials';
    }
    if (msg.contains('email already') || msg.contains('already registered')) {
      return 'err_email_taken';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'err_rate_limit';
    }
    if (msg.contains('user not found') || msg.contains('no user found')) {
      return 'err_user_not_found';
    }
    if (msg.contains('network')) return 'err_network';
    if (msg.contains('cancelled') || msg.contains('google_cancelled')) {
      return 'err_cancelled';
    }
    if (msg.contains('weak password')) return 'err_weak_password';
    if (msg.contains('row-level security') ||
        msg.contains('permission denied')) {
      return 'err_permission';
    }

    return 'err_unknown';
  }
}
