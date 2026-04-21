import 'package:aqar_hub/core/helpers/prefs_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  ProfileCubit(this._repo) : super(ProfileInitial());

  // ── Safe emit ──────────────────────────────────────────────────────────────
  void _safeEmit(ProfileState s) {
    if (!isClosed) emit(s);
  }

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> loadProfile(String uid, {bool forceRefresh = false}) async {
    final cached = PrefsHelper.getCachedProfile();

    if (cached != null) {
      _safeEmit(ProfileLoaded(ProfileModel.fromMap(cached)));
      if (!forceRefresh) return; // cache hit — no network call needed
    } else {
      _safeEmit(ProfileLoading()); // no cache → show spinner
    }

    final result = await _repo.getProfile(uid);
    result.fold((err) => _safeEmit(ProfileError(err)), (profile) {
      PrefsHelper.cacheProfile(profile.toMap());
      _safeEmit(ProfileLoaded(profile));
    });
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> updateProfile(ProfileModel updated) async {
    final current = _current;
    if (current == null) return;
    _safeEmit(ProfileUpdating(current));
    final result = await _repo.updateProfile(updated);
    result.fold((err) => _safeEmit(ProfileError(err)), (profile) {
      PrefsHelper.cacheProfile(profile.toMap());
      _safeEmit(ProfileUpdated(profile));
    });
  }

  // ── Change Password ────────────────────────────────────────────────────────
  Future<void> changePassword(String newPassword) async {
    _safeEmit(ProfileChangingPassword());
    final result = await _repo.changePassword(newPassword);
    result.fold(
      (err) => _safeEmit(ProfileError(err)),
      (_) => _safeEmit(ProfilePasswordChanged()),
    );
  }

  // ── Clear cache on logout ──────────────────────────────────────────────────
  void clearCache() {
    PrefsHelper.clearProfile();
    _safeEmit(ProfileInitial());
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  ProfileModel? get _current => switch (state) {
    ProfileLoaded(:final profile) => profile,
    ProfileUpdating(:final profile) => profile,
    ProfileUpdated(:final profile) => profile,
    _ => null,
  };
}
