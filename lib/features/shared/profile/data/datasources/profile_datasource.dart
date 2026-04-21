import '../models/profile_model.dart';

abstract interface class ProfileDatasource {
  Future<ProfileModel> getProfile(String uid);
  Future<void> updateProfile(ProfileModel model);
}
