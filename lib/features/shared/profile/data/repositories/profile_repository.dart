import 'package:dartz/dartz.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<String, ProfileModel>> getProfile(String uid);
  Future<Either<String, ProfileModel>> updateProfile(ProfileModel profile);
  Future<Either<String, void>> changePassword(String newPassword);
}
