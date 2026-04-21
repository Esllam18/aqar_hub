import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/helpers/onboarding_cache_helper.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/features/auth/presentation/views/login_view.dart';
import 'package:aqar_hub/features/onboarding/data/datasources/onboarding_data.dart';
import 'package:aqar_hub/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aqar_hub/features/onboarding/presentation/cubit/onboarding_state.dart';

import 'package:aqar_hub/features/onboarding/presentation/widgets/onboarding_button_widget.dart';
import 'package:aqar_hub/features/onboarding/presentation/widgets/onboarding_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final current = context.read<OnboardingCubit>().getCurrentPage();
    if (current < OnboardingData.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    context.read<OnboardingCubit>().completeOnboarding();
    await OnboardingCacheHelper.setSeen();
    Navigation.offAll(const LoginView(), transition: TransitionType.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, _) {
            final currentPage = context
                .read<OnboardingCubit>()
                .getCurrentPage();
            return Column(
              children: [
                Expanded(
                  child: OnboardingContentWidget(
                    pageController: _pageController,
                    onPageChanged: context
                        .read<OnboardingCubit>()
                        .onPageChanged,
                  ),
                ),
                OnboardingBottomWidget(
                  currentPage: currentPage,
                  onNext: _onNext,
                  onSkip: _complete,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
