import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserModel> signUpWithEmail(String email, String password) =>
      _dataSource.signUpWithEmail(email, password);

  @override
  Future<UserModel> signInWithEmail(String email, String password) =>
      _dataSource.signInWithEmail(email, password);

  @override
  Future<UserModel> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> sendPasswordReset(String email) =>
      _dataSource.sendPasswordReset(email);

  @override
  Future<void> updatePassword(String newPassword) =>
      _dataSource.updatePassword(newPassword);

  @override
  Future<void> saveRole(String uid, String role) =>
      _dataSource.saveRole(uid, role);

  @override
  Future<void> saveProfile(UserModel user) => _dataSource.saveProfile(user);

  @override
  Future<UserModel?> getProfile(String uid) => _dataSource.getProfile(uid);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  UserModel? getCurrentUser() => _dataSource.getCurrentUser();
}
