import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/home/presentation/cubit/owner_sale_properties_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches ALL owner properties then filters for sale client-side.
class OwnerSalePropertiesCubit extends Cubit<OwnerSalePropertiesState> {
  final OwnerPropertiesRepositoryImpl repository;

  OwnerSalePropertiesCubit(this.repository)
    : super(const OwnerSalePropertiesInitial());

  String? get ownerId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> load({bool showLoading = true}) async {
    final uid = ownerId;
    if (uid == null || uid.isEmpty) {
      emit(const OwnerSalePropertiesError('Please sign in first.'));
      return;
    }

    // ── Serve cached data instantly ────────────────────────────────────────
    // Owner properties cache is shared with OwnerHomeCubit (same key).
    // We filter for 'sale' locally just like we do from the network.
    final cached = AppPrefs.getCachedOwnerProperties();
    if (cached != null && cached.isNotEmpty) {
      try {
        final all = _fromCacheList(cached);
        final sale = all.where((e) => e.listingType == 'sale').toList();
        emit(OwnerSalePropertiesLoaded(properties: sale));
        _backgroundRefresh(uid);
        return;
      } catch (_) {}
    }

    if (showLoading) emit(const OwnerSalePropertiesLoading());

    try {
      final all = await repository.getOwnerProperties(uid);
      // Write to shared cache so OwnerHomeCubit can use it too
      _writeCache(all);
      final sale = all.where((e) => e.listingType == 'sale').toList();
      emit(OwnerSalePropertiesLoaded(properties: sale));
    } catch (e, s) {
      debugPrint('OwnerSalePropertiesCubit.load error: $e');
      debugPrintStack(stackTrace: s);
      emit(OwnerSalePropertiesError(_mapError(e)));
    }
  }

  Future<void> _backgroundRefresh(String uid) async {
    try {
      final all = await repository.getOwnerProperties(uid);
      _writeCache(all);
      final sale = all.where((e) => e.listingType == 'sale').toList();
      if (!isClosed) emit(OwnerSalePropertiesLoaded(properties: sale));
    } catch (_) {}
  }

  Future<void> refresh() async {
    AppPrefs.clearOwnerPropertiesCache();
    return load(showLoading: false);
  }

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

  String _mapError(Object error) {
    if (error is PostgrestException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Database request failed.';
    }
    if (error is AuthException) return error.message;
    return error.toString();
  }
}
