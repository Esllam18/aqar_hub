import 'package:aqar_hub/core/helpers/onboarding_cache_helper.dart';
import 'package:aqar_hub/core/localization/language_cache_helper.dart';
import 'package:aqar_hub/core/localization/locale_cubit.dart';
import 'package:aqar_hub/core/services/navigation/app_routes.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/language/widgets/language_continue_button_widget.dart';
import 'package:aqar_hub/features/language/widgets/language_header_widget.dart';
import 'package:aqar_hub/features/language/widgets/language_options_widget.dart';
import 'package:aqar_hub/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aqar_hub/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  String _selectedCode = 'ar';

  void _select(String code) {
    if (_selectedCode == code) return;
    setState(() => _selectedCode = code);
  }

  Future<void> _onContinue() async {
    await LanguageCacheHelper.setLanguage(_selectedCode);

    if (mounted) {
      context.read<LocaleCubit>().changeLanguage(_selectedCode);
    }

    final onboardingSeen = await OnboardingCacheHelper.isSeen();
    if (onboardingSeen) {
      Navigation.offAllNamed(AppRoutes.login);
    } else {
      Navigation.offAll(
        BlocProvider(
          create: (_) => OnboardingCubit(),
          child: const OnboardingView(),
        ),
        transition: TransitionType.fade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: context.rSymmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const Spacer(),
                const LanguageHeaderWidget(),
                SizedBox(height: context.r(40)),
                LanguageOptionsWidget(
                  selectedCode: _selectedCode,
                  onSelect: _select,
                ),
                const Spacer(),
                LanguageContinueButton(
                  selectedCode: _selectedCode,
                  onPressed: _onContinue,
                ),
                SizedBox(height: context.r(8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
