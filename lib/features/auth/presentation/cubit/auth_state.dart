part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthPasswordUpdated extends AuthState {
  const AuthPasswordUpdated();
}

class AuthGuestMode extends AuthState {
  const AuthGuestMode();
}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNeedsRoleSelection extends AuthState {
  final UserModel user;
  const AuthNeedsRoleSelection(this.user);
}

class AuthNeedsProfileCompletion extends AuthState {
  final UserModel user;
  const AuthNeedsProfileCompletion(this.user);
}
