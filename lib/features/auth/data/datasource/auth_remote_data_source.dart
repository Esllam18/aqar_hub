import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> saveRole(String uid, String role);
  Future<void> saveProfile(UserModel user);
  Future<UserModel?> getProfile(String uid);
  Future<void> signOut();
  UserModel? getCurrentUser();
}
