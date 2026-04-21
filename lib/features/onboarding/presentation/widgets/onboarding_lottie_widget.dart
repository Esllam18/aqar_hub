import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingLottieWidget extends StatelessWidget {
  final String lottiePath;

  const OnboardingLottieWidget({super.key, required this.lottiePath});

  @override
  Widget build(BuildContext context) {
    final size = context.responsive<double>(
      mobile: context.h(0.42),
      tablet: context.h(0.45),
      desktop: context.h(0.48),
    );

    return AppAnimations.combined(
      type: CombineType.fadeScale,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      beginScale: 0.6,
      child: Lottie.asset(
        lottiePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }
}
