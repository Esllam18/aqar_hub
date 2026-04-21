import 'dart:io';
import 'package:aqar_hub/features/owner/home/data/datasources/owner_properties_remote_datasource.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';

class OwnerPropertiesRepositoryImpl {
  final OwnerPropertiesRemoteDatasource _ds;

  OwnerPropertiesRepositoryImpl(this._ds);

  Future<List<OwnerPropertyModel>> getOwnerProperties(String ownerId) async {
    final rawList = await _ds.fetchOwnerProperties(ownerId);
    return rawList.map((raw) {
      final rawOptions = raw['rental_options'];
      final options = rawOptions is List
          ? rawOptions
                .map(
                  (e) => RentalOptionModel.fromMap(e as Map<String, dynamic>),
                )
                .toList()
          : <RentalOptionModel>[];
      return OwnerPropertyModel.fromMap(raw, options);
    }).toList();
  }

  Future<void> updateDescription({
    required String propertyId,
    required String description,
  }) => _ds.updateDescription(propertyId: propertyId, description: description);

  Future<void> updateRentedStatus({
    required String propertyId,
    required bool isRented,
  }) => _ds.updateRentedStatus(propertyId: propertyId, isRented: isRented);

  Future<void> updateRentalAvailability({
    required String optionId,
    required int availableQuantity,
  }) => _ds.updateRentalAvailability(
    optionId: optionId,
    availableQuantity: availableQuantity,
  );

  Future<void> deleteProperty(String propertyId) =>
      _ds.deleteProperty(propertyId);

  Future<void> updateProperty({
    required String propertyId,
    required Map<String, dynamic> fields,
  }) => _ds.updateProperty(propertyId: propertyId, fields: fields);

  Future<void> upsertRentalOptions({
    required String propertyId,
    required List<RentalOptionModel> options,
  }) => _ds.upsertRentalOptions(propertyId: propertyId, options: options);

  Future<void> deleteRentalOption(String optionId) =>
      _ds.deleteRentalOption(optionId);

  Future<List<String>> uploadImages({
    required String ownerId,
    required List<File> files,
  }) => _ds.uploadImages(ownerId: ownerId, files: files);
}
