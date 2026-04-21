import 'package:aqar_hub/core/constants/app_durations.dart';
import 'package:aqar_hub/core/enums/app_role.dart'; // ✅
import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/core/helpers/onboarding_cache_helper.dart';
import 'package:aqar_hub/core/localization/language_cache_helper.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/features/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:aqar_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/complete_profile_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/login_view.dart';
import 'package:aqar_hub/layout/views/main_layout_view.dart';
import 'package:aqar_hub/features/language/views/language_selection_view.dart';
import 'package:aqar_hub/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aqar_hub/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class SplashNavigator {
  static Future<void> navigate() async {
    await Future.delayed(AppDurations.extraLong);

    // ── 1. Language ───────────────────────────────────────────────────────
    final langSelected = await LanguageCacheHelper.isLanguageSelected();
    if (!langSelected) return _go(const LanguageSelectionView());

    // ── 2. Onboarding ─────────────────────────────────────────────────────
    final onboardingSeen = await OnboardingCacheHelper.isSeen();
    if (!onboardingSeen) {
      return _go(
        BlocProvider(
          create: (_) => OnboardingCubit(),
          child: const OnboardingView(),
        ),
      );
    }

    // ── 3. Auth state ─────────────────────────────────────────────────────
    final loggedIn = await AppPrefs.isLoggedIn();
    if (!loggedIn) return _goToLogin();

    // ── 4. Needs profile completion? ──────────────────────────────────────
    final needsProfile = await AppPrefs.needsProfile();
    if (needsProfile) {
      final uid = await AppPrefs.getUserId();
      final role = await AppPrefs.getUserRole();
      return _go(
        BlocProvider(
          create: (_) =>
              AuthCubit(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
          child: CompleteProfileView(
            initialUid: uid,
            initialRole: role ?? 'seeker',
          ),
        ),
      );
    }

    // ── 5. Role-based routing ─────────────────────────────────────────────
    final roleStr = await AppPrefs.getUserRole();
    // ✅ Map string → AppRole enum cleanly
    final appRole = roleStr == 'owner' ? AppRole.owner : AppRole.seeker;
    _go(MainLayoutView(role: appRole));
  }

  static void _goToLogin() => _go(
    BlocProvider(
      create: (_) => AuthCubit(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
      child: const LoginView(),
    ),
  );

  static void _go(Widget page) =>
      Navigation.offAll(page, transition: TransitionType.fade);
}
