import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';

sealed class EditPropertyState {
  const EditPropertyState();
}

final class EditPropertyInitial extends EditPropertyState {
  const EditPropertyInitial();
}

final class EditPropertyLoading extends EditPropertyState {
  const EditPropertyLoading();
}

final class EditPropertySuccess extends EditPropertyState {
  final OwnerPropertyModel updatedProperty;
  const EditPropertySuccess(this.updatedProperty);
}

final class EditPropertyError extends EditPropertyState {
  final String message;
  const EditPropertyError(this.message);
}
