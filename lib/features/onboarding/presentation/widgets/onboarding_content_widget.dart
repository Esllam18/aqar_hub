import 'package:aqar_hub/features/onboarding/data/datasources/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'onboarding_page_widget.dart';

class OnboardingContentWidget extends StatelessWidget {
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const OnboardingContentWidget({
    super.key,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: OnboardingData.pages.length,
      itemBuilder: (_, i) =>
          OnboardingPageWidget(page: OnboardingData.pages[i]),
    );
  }
}
