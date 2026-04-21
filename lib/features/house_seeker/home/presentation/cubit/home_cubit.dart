import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/property_filter_model.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PropertyRepository _repository;
  static const int _pageSize = 10;

  HomeCubit(this._repository) : super(HomeInitial());

  void _safeEmit(HomeState s) {
    if (!isClosed) emit(s);
  }

  // ── Initial / refresh load ────────────────────────────────────────────────
  // For the default (no-filter) first page we check the 5-min SharedPrefs
  // cache first so the feed renders instantly on app launch.
  // A background fetch always runs to keep the cache fresh.

  Future<void> loadProperties({PropertyFilterModel? filter}) async {
    final f = filter ?? const PropertyFilterModel.empty();
    final useCache = f == const PropertyFilterModel.empty();

    if (useCache) {
      final cached = AppPrefs.getCachedProperties();
      if (cached != null && cached.isNotEmpty) {
        try {
          // Restore from the plain Maps written by toMap()
          final models = cached.map((m) => PropertyModel.fromMap(m)).toList();
          _safeEmit(
            HomeLoaded(
              properties: models,
              hasMore: models.length == _pageSize,
              page: 0,
              filter: f,
            ),
          );
          // Silently refresh in the background
          _backgroundRefresh(f);
          return;
        } catch (_) {
          // Corrupted cache — fall through to normal load
        }
      }
    }

    _safeEmit(HomeLoading());
    try {
      final result = await _repository.getProperties(
        filter: f,
        page: 0,
        pageSize: _pageSize,
      );
      if (useCache) _writeCache(result);
      _safeEmit(
        HomeLoaded(
          properties: result,
          hasMore: result.length == _pageSize,
          page: 0,
          filter: f,
        ),
      );
    } catch (_) {
      _safeEmit(HomeError('err_network'));
    }
  }

  /// Fetches fresh data silently and updates the cache without showing a spinner.
  Future<void> _backgroundRefresh(PropertyFilterModel f) async {
    try {
      final result = await _repository.getProperties(
        filter: f,
        page: 0,
        pageSize: _pageSize,
      );
      _writeCache(result);
      _safeEmit(
        HomeLoaded(
          properties: result,
          hasMore: result.length == _pageSize,
          page: 0,
          filter: f,
        ),
      );
    } catch (_) {
      // Silently ignore — user already sees cached data
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final current = state;
    if (current is! HomeLoaded) return;
    if (current is HomeLoadingMore) return;
    if (!current.hasMore) return;

    _safeEmit(
      HomeLoadingMore(
        properties: current.properties,
        hasMore: current.hasMore,
        page: current.page,
        filter: current.filter,
      ),
    );

    try {
      final nextPage = current.page + 1;
      final result = await _repository.getProperties(
        filter: current.filter,
        page: nextPage,
        pageSize: _pageSize,
      );
      _safeEmit(
        HomeLoaded(
          properties: [...current.properties, ...result],
          hasMore: result.length == _pageSize,
          page: nextPage,
          filter: current.filter,
        ),
      );
    } catch (_) {
      _safeEmit(
        HomeLoaded(
          properties: current.properties,
          hasMore: false,
          page: current.page,
          filter: current.filter,
        ),
      );
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  Future<void> applyFilter(PropertyFilterModel filter) =>
      loadProperties(filter: filter);

  Future<void> refresh() {
    AppPrefs.clearPropertiesCache();
    final current = state;
    final filter = current is HomeLoaded ? current.filter : null;
    return loadProperties(filter: filter);
  }

  // ── Cache helper ──────────────────────────────────────────────────────────

  void _writeCache(List<PropertyModel> list) {
    try {
      AppPrefs.cacheProperties(list.map((p) => p.toMap()).toList());
    } catch (_) {}
  }
}
