// lib/features/owner/home/presentation/cubit/edit_property_cubit.dart
//
// Extended to accept imageUrls (final list after edits) and
// newImageFiles (newly picked files to upload before saving).

import 'dart:io';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/edit_property/cubit/edit_property_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPropertyCubit extends Cubit<EditPropertyState> {
  final OwnerPropertiesRepositoryImpl repository;
  final OwnerPropertyModel original;

  EditPropertyCubit({required this.repository, required this.original})
    : super(const EditPropertyInitial());

  Future<void> save({
    required String title,
    required String description,
    required String address,
    required String city,
    required int? totalRooms,
    required int? totalBeds,
    required int? bathrooms,
    required double? areaM2,
    required bool isFurnished,
    required String listingType,
    required String targetAudience,
    required String propertyType,
    required double? basePrice,
    required bool isRented,
    required List<RentalOptionModel> rentalOptions,
    // Image editing
    required List<String> keptImageUrls, // existing URLs that were NOT deleted
    required List<File> newImageFiles, // newly picked files to upload
  }) async {
    emit(const EditPropertyLoading());

    try {
      final ownerId = Supabase.instance.client.auth.currentUser?.id ?? '';

      // 1. Upload new images (if any)
      List<String> uploadedUrls = [];
      if (newImageFiles.isNotEmpty && ownerId.isNotEmpty) {
        uploadedUrls = await repository.uploadImages(
          ownerId: ownerId,
          files: newImageFiles,
        );
      }

      // 2. Final image list = kept existing + newly uploaded
      final finalImageUrls = [...keptImageUrls, ...uploadedUrls];

      // 3. Build update payload
      final fields = <String, dynamic>{
        'title': title,
        'description': description,
        'address': address,
        'city': city,
        'is_furnished': isFurnished,
        'listing_type': listingType,
        'target_audience': targetAudience,
        'property_type': propertyType,
        'is_rented': isRented,
        'image_urls': finalImageUrls,
        if (totalRooms != null) 'total_rooms': totalRooms,
        if (totalBeds != null) 'total_beds': totalBeds,
        if (bathrooms != null) 'bathrooms': bathrooms,
        if (areaM2 != null) 'area_m2': areaM2,
        if (basePrice != null) 'base_price': basePrice,
      };

      await repository.updateProperty(propertyId: original.id, fields: fields);

      // 4. Update rental options if listing type is rent
      if (listingType == 'rent' && rentalOptions.isNotEmpty) {
        await repository.upsertRentalOptions(
          propertyId: original.id,
          options: rentalOptions,
        );
      }

      final updated = original.copyWith(
        title: title,
        description: description,
        address: address,
        city: city,
        totalRooms: totalRooms,
        totalBeds: totalBeds,
        bathrooms: bathrooms,
        areaM2: areaM2,
        isFurnished: isFurnished,
        listingType: listingType,
        targetAudience: targetAudience,
        propertyType: propertyType,
        basePrice: basePrice,
        isRented: isRented,
        rentalOptions: rentalOptions,
        imageUrls: finalImageUrls,
      );

      emit(EditPropertySuccess(updated));
    } catch (e, s) {
      debugPrint('EditPropertyCubit.save error: $e');
      debugPrintStack(stackTrace: s);
      emit(EditPropertyError(e.toString()));
    }
  }
}
