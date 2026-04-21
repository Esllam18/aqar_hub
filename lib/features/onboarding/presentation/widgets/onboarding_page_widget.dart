import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/onboarding/data/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'onboarding_description_widget.dart';
import 'onboarding_lottie_widget.dart';
import 'onboarding_title_widget.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rSymmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          OnboardingLottieWidget(lottiePath: page.lottie),

          SizedBox(height: context.r(32)),

          OnboardingTitleWidget(titleKey: page.titleKey),

          SizedBox(height: context.r(12)),

          OnboardingDescriptionWidget(descriptionKey: page.descriptionKey),

          const Spacer(),
        ],
      ),
    );
  }
}
