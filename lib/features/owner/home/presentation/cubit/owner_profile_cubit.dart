import 'package:aqar_hub/features/owner/home/data/datasources/owner_profile_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'owner_profile_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OwnerProfileCubit
//
// Mirrors the pattern from ProfileCubit:
//   - Uses safe emit (_safeEmit) to guard against closed cubit
//   - Fetches profile + properties in parallel for speed
//   - Never throws — errors are caught and emitted as OwnerProfileError
//
// File path:
//   lib/features/house_seeker/home/presentation/cubit/owner_profile_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────

class OwnerProfileCubit extends Cubit<OwnerProfileState> {
  final OwnerProfileDatasource _datasource;

  OwnerProfileCubit(this._datasource) : super(const OwnerProfileInitial());

  // ── Safe emit (guards against "emit after close") ─────────────────────────
  void _safeEmit(OwnerProfileState s) {
    if (!isClosed) emit(s);
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> load(String ownerId) async {
    _safeEmit(const OwnerProfileLoading());
    try {
      // Run both fetches in parallel
      final results = await Future.wait([
        _datasource.fetchProfile(ownerId),
        _datasource.fetchProperties(ownerId),
      ]);

      final profile = results[0];
      final properties =
          (results[1] as List<Map<String, dynamic>>?) ??
          <Map<String, dynamic>>[];
      final userMeta = _datasource.fetchCurrentUserMeta(ownerId);

      _safeEmit(
        OwnerProfileLoaded(
          profile: profile as dynamic,
          userMeta: userMeta,
          properties: properties,
        ),
      );
    } catch (e) {
      _safeEmit(OwnerProfileError(e.toString()));
    }
  }

  Future<void> reload(String ownerId) => load(ownerId);
}
