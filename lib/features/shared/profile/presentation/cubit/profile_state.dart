part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileChangingPassword extends ProfileState {}

final class ProfilePasswordChanged extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  ProfileLoaded(this.profile);
}

final class ProfileUpdating extends ProfileState {
  final ProfileModel profile;
  ProfileUpdating(this.profile);
}

final class ProfileUpdated extends ProfileState {
  final ProfileModel profile;
  ProfileUpdated(this.profile);
}

final class ProfileError extends ProfileState {
  final String messageKey;
  ProfileError(this.messageKey);
}
