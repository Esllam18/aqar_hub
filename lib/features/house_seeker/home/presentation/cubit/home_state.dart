import '../../data/models/property_filter_model.dart';
import '../../data/models/property_model.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<PropertyModel> properties;
  final bool hasMore;
  final int page;
  final PropertyFilterModel filter;

  HomeLoaded({
    required this.properties,
    required this.hasMore,
    required this.page,
    required this.filter,
  });
}

final class HomeLoadingMore extends HomeLoaded {
  HomeLoadingMore({
    required super.properties,
    required super.hasMore,
    required super.page,
    required super.filter,
  });
}

final class HomeError extends HomeState {
  final String messageKey;
  HomeError(this.messageKey);
}
