part of 'favorites_cubit.dart';

sealed class FavoritesState {
  const FavoritesState();
}

final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

final class FavoritesIdsLoaded extends FavoritesState {
  final Set<String> ids;
  const FavoritesIdsLoaded({required this.ids});
}

final class FavoritesLoaded extends FavoritesState {
  final List<PropertyModel> properties;
  final Set<String> ids;
  const FavoritesLoaded({required this.properties, required this.ids});
}

final class FavoritesError extends FavoritesState {
  final String messageKey;
  const FavoritesError(this.messageKey);
}
