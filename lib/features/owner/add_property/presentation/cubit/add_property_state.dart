sealed class AddPropertyState {
  const AddPropertyState();
}

final class AddPropertyInitial extends AddPropertyState {
  const AddPropertyInitial();
}

final class AddPropertyLoading extends AddPropertyState {
  const AddPropertyLoading();
}

final class AddPropertySuccess extends AddPropertyState {
  final String propertyId;
  const AddPropertySuccess(this.propertyId);
}

final class AddPropertyError extends AddPropertyState {
  final String message;
  const AddPropertyError(this.message);
}
