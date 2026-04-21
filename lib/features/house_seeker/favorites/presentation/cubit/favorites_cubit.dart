import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../../home/data/models/property_model.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesInitial());

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  // ── Load favorite IDs only (used by home screen heart icons) ──────────────
  // Reads from AppPrefs cache first for instant heart rendering.
  Future<void> loadFavoriteIds() async {
    final uid = _userId;
    if (uid == null) return;

    // Restore from cache immediately
    final cached = AppPrefs.getCachedFavIds();
    if (cached.isNotEmpty) {
      if (!isClosed) emit(FavoritesIdsLoaded(ids: Set.from(cached)));
    }

    // Always refresh from network
    try {
      final ids = await _repository.getFavoriteIds(uid);
      await AppPrefs.cacheFavIds(ids);
      if (!isClosed) emit(FavoritesIdsLoaded(ids: Set.from(ids)));
    } catch (_) {
      // Network failure is non-fatal when cache hit already happened
    }
  }

  // ── Load full property objects (used by favorites screen) ──────────────────
  Future<void> loadFavoriteProperties() async {
    final uid = _userId;
    if (uid == null) {
      emit(const FavoritesError('err_not_logged_in'));
      return;
    }
    if (!isClosed) emit(const FavoritesLoading());
    try {
      final properties = await _repository.getFavoriteProperties(uid);
      final ids = properties.map((p) => p.id).toSet();
      await AppPrefs.cacheFavIds(ids.toList());
      if (!isClosed) emit(FavoritesLoaded(properties: properties, ids: ids));
    } catch (_) {
      if (!isClosed) emit(const FavoritesError('err_network'));
    }
  }

  // ── Toggle (add / remove) ──────────────────────────────────────────────────
  Future<void> toggle(String propertyId) async {
    final uid = _userId;
    if (uid == null) return;

    final currentIds = _currentIds;
    final isCurrentlyFavorite = currentIds.contains(propertyId);
    final updatedIds = Set<String>.from(currentIds);
    if (isCurrentlyFavorite) {
      updatedIds.remove(propertyId);
    } else {
      updatedIds.add(propertyId);
    }

    // Optimistic update
    _emitUpdatedIds(updatedIds);
    await AppPrefs.cacheFavIds(updatedIds.toList());

    try {
      if (isCurrentlyFavorite) {
        await _repository.removeFavorite(uid, propertyId);
      } else {
        await _repository.addFavorite(uid, propertyId);
      }
      if (state is FavoritesLoaded && isCurrentlyFavorite) {
        final loaded = state as FavoritesLoaded;
        final updatedProps = loaded.properties
            .where((p) => p.id != propertyId)
            .toList();
        if (!isClosed) {
          emit(FavoritesLoaded(properties: updatedProps, ids: updatedIds));
        }
      }
    } catch (_) {
      // Revert optimistic update
      final revertedIds = Set<String>.from(currentIds);
      _emitUpdatedIds(revertedIds);
      await AppPrefs.cacheFavIds(revertedIds.toList());
    }
  }

  bool isFavorite(String propertyId) => _currentIds.contains(propertyId);

  // ── Helpers ────────────────────────────────────────────────────────────────
  Set<String> get _currentIds => switch (state) {
    FavoritesIdsLoaded s => s.ids,
    FavoritesLoaded s => s.ids,
    _ => {},
  };

  void _emitUpdatedIds(Set<String> ids) {
    switch (state) {
      case FavoritesLoaded s:
        if (!isClosed) {
          emit(FavoritesLoaded(properties: s.properties, ids: ids));
        }
      default:
        if (!isClosed) emit(FavoritesIdsLoaded(ids: ids));
    }
  }
}
