import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/owner_sale/presentation/cubit/owner_home_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerHomeCubit extends Cubit<OwnerHomeState> {
  final OwnerPropertiesRepositoryImpl repository;

  OwnerHomeCubit(this.repository) : super(const OwnerHomeInitial());

  String? get ownerId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> load({bool showLoading = true}) async {
    final uid = ownerId;
    if (uid == null || uid.isEmpty) {
      emit(const OwnerHomeError('Please sign in first.'));
      return;
    }

    // ── Serve cache instantly ──────────────────────────────────────────────
    final cached = AppPrefs.getCachedOwnerProperties();
    if (cached != null && cached.isNotEmpty) {
      try {
        final models = _fromCacheList(cached);
        emit(OwnerHomeLoaded(properties: models));
        // Silently refresh in background
        _backgroundRefresh(uid);
        return;
      } catch (_) {
        // Corrupted cache — fall through
      }
    }

    if (showLoading) emit(const OwnerHomeLoading());

    try {
      final properties = await repository.getOwnerProperties(uid);
      _writeCache(properties);
      emit(OwnerHomeLoaded(properties: properties));
    } catch (e, s) {
      debugPrint('OwnerHomeCubit.load error: $e');
      debugPrintStack(stackTrace: s);
      emit(OwnerHomeError(_mapErrorMessage(e)));
    }
  }

  Future<void> _backgroundRefresh(String uid) async {
    try {
      final properties = await repository.getOwnerProperties(uid);
      _writeCache(properties);
      if (!isClosed) emit(OwnerHomeLoaded(properties: properties));
    } catch (_) {}
  }

  Future<void> refresh() async {
    AppPrefs.clearOwnerPropertiesCache();
    return load(showLoading: false);
  }

  // ── Mutation helpers (unchanged logic, cache cleared after each) ──────────

  Future<bool> saveDescription({
    required String propertyId,
    required String description,
  }) async {
    try {
      await repository.updateDescription(
        propertyId: propertyId,
        description: description,
      );
      await refresh();
      return true;
    } catch (e, s) {
      debugPrint('saveDescription error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  Future<bool> toggleRented({
    required String propertyId,
    required bool isRented,
  }) async {
    try {
      await repository.updateRentedStatus(
        propertyId: propertyId,
        isRented: isRented,
      );
      await refresh();
      return true;
    } catch (e, s) {
      debugPrint('toggleRented error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  Future<bool> updateOptionAvailability({
    required RentalOptionModel option,
    required int availableQuantity,
  }) async {
    try {
      await repository.updateRentalAvailability(
        optionId: option.id,
        availableQuantity: availableQuantity,
      );
      await refresh();
      return true;
    } catch (e, s) {
      debugPrint('updateOptionAvailability error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    try {
      await repository.deleteProperty(propertyId);
      await refresh();
      return true;
    } catch (e, s) {
      debugPrint('deleteProperty error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  Future<bool> updatePropertyDetails({
    required String propertyId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await repository.updateProperty(propertyId: propertyId, fields: data);
      await refresh();
      return true;
    } catch (e, stackTrace) {
      debugPrint('updatePropertyDetails error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  void _writeCache(List<OwnerPropertyModel> list) {
    try {
      AppPrefs.cacheOwnerProperties(list.map((p) => p.toMap()).toList());
    } catch (_) {}
  }

  List<OwnerPropertyModel> _fromCacheList(List<Map<String, dynamic>> list) {
    return list.map((m) {
      final optionsRaw = m['rental_options'] as List? ?? [];
      final options = optionsRaw
          .map((o) => RentalOptionModel.fromMap(o as Map<String, dynamic>))
          .toList();
      return OwnerPropertyModel.fromMap(m, options);
    }).toList();
  }

  String _mapErrorMessage(Object error) {
    if (error is PostgrestException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Database request failed.';
    }
    if (error is AuthException) return error.message;
    return error.toString();
  }
}
