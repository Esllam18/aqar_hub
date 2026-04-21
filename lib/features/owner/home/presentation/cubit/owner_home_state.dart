// lib/features/owner/home/presentation/cubit/owner_home_state.dart

import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';

sealed class OwnerHomeState {
  const OwnerHomeState();
}

final class OwnerHomeInitial extends OwnerHomeState {
  const OwnerHomeInitial();
}

final class OwnerHomeLoading extends OwnerHomeState {
  const OwnerHomeLoading();
}

final class OwnerHomeLoaded extends OwnerHomeState {
  final List<OwnerPropertyModel> properties;

  const OwnerHomeLoaded({required this.properties});

  bool get isEmpty => properties.isEmpty;
  int get totalCount => properties.length;
  int get saleCount => properties.where((e) => e.isForSale).length;
  int get rentCount => properties.where((e) => !e.isForSale).length;
  int get rentedCount => properties.where((e) => e.isRented).length;
  int get availableCount =>
      properties.where((e) => !e.isRented && !e.isForSale).length;
  int get alertsCount =>
      properties.where((e) => e.alerts.any((a) => a.code != 'available')).length;

  double get totalRevenue => properties.fold(
        0.0,
        (sum, p) => sum + (p.displayPrice ?? 0.0),
      );
}

final class OwnerHomeError extends OwnerHomeState {
  final String message;
  const OwnerHomeError(this.message);
}
