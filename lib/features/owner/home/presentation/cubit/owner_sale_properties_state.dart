import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';

sealed class OwnerSalePropertiesState {
  const OwnerSalePropertiesState();
}

final class OwnerSalePropertiesInitial extends OwnerSalePropertiesState {
  const OwnerSalePropertiesInitial();
}

final class OwnerSalePropertiesLoading extends OwnerSalePropertiesState {
  const OwnerSalePropertiesLoading();
}

final class OwnerSalePropertiesLoaded extends OwnerSalePropertiesState {
  final List<OwnerPropertyModel> properties;
  final bool hasMore;
  final bool loadingMore;

  const OwnerSalePropertiesLoaded({
    required this.properties,
    this.hasMore = false,
    this.loadingMore = false,
  });

  bool get isEmpty => properties.isEmpty;

  OwnerSalePropertiesLoaded copyWith({
    List<OwnerPropertyModel>? properties,
    bool? hasMore,
    bool? loadingMore,
  }) => OwnerSalePropertiesLoaded(
    properties: properties ?? this.properties,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

final class OwnerSalePropertiesError extends OwnerSalePropertiesState {
  final String message;

  const OwnerSalePropertiesError(this.message);
}
