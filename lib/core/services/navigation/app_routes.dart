import 'package:aqar_hub/features/auth/presentation/views/complete_profile_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/forgot_password_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/login_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/reset_password_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/role_selection_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/sign_up_view.dart';
import 'package:aqar_hub/features/house_seeker/favorites/presentation/views/favorites_view.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/home_view.dart';
import 'package:aqar_hub/features/language/views/language_selection_view.dart';
import 'package:aqar_hub/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aqar_hub/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String completeProfile = '/complete-profile';
  static const String roleSelection = '/role-selection';
  static const String resetPassword = '/reset-password';
  static const String forgotPassword = '/forgot-password';
  static const String signUp = '/sign-up';
  // Fixed: was '/proflie' (typo), now '/profile'
  static const String profile = '/profile';
  static const String favorites = '/favorites';

  static Map<String, WidgetBuilder> get routes => {
    language: (_) => const LanguageSelectionView(),
    onboarding: (_) => BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const OnboardingView(),
    ),
    login: (_) => const LoginView(),
    completeProfile: (_) => const CompleteProfileView(),
    roleSelection: (_) => const RoleSelectionView(),
    resetPassword: (_) => const ResetPasswordView(),
    forgotPassword: (_) => const ForgotPasswordView(),
    signUp: (_) => const SignUpView(),
    // Fixed: was mapping to SignUpView — now points to HomeView as fallback
    // (ProfileView requires role + uid injected at layout level, not via named route)
    profile: (_) => const HomeView(),
    home: (_) => const HomeView(),
    favorites: (_) => const FavoritesView(),
  };
}
