import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/profile_datasource.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _ds;
  ProfileRepositoryImpl(this._ds);

  @override
  Future<Either<String, ProfileModel>> getProfile(String uid) async {
    try {
      return Right(await _ds.getProfile(uid));
    } catch (e) {
      return const Left('profile_error_load');
    }
  }

  @override
  Future<Either<String, ProfileModel>> updateProfile(ProfileModel p) async {
    try {
      await _ds.updateProfile(p);
      return Right(p);
    } catch (e) {
      return const Left('profile_error_update');
    }
  }

  @override
  Future<Either<String, void>> changePassword(String newPassword) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Right(null);
    } catch (e) {
      return const Left('profile_error_change_password');
    }
  }
}
