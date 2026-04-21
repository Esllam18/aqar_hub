import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/onboarding/data/datasources/onboarding_data.dart';
import 'package:aqar_hub/features/onboarding/presentation/widgets/onboarding_bottom_widget.dart';
import 'package:flutter/material.dart';
import 'page_indicator_widget.dart';

class OnboardingBottomWidget extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingBottomWidget({
    super.key,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == OnboardingData.pages.length - 1;

    return AppAnimations.fade(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: context.rAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PageIndicatorWidget(
              currentPage: currentPage,
              pageCount: OnboardingData.pages.length,
            ),

            SizedBox(height: context.r(32)),

            if (isLastPage)
              OnboardingButtonWidget(
                text: 'onboarding_btn_start'.tr(context),
                onPressed: onNext,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OnboardingButtonWidget(
                      text: 'onboarding_btn_skip'.tr(context),
                      onPressed: onSkip,
                      isOutlined: true,
                    ),
                  ),
                  SizedBox(width: context.r(16)),
                  Expanded(
                    child: OnboardingButtonWidget(
                      text: 'onboarding_btn_next'.tr(context),
                      onPressed: onNext,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
