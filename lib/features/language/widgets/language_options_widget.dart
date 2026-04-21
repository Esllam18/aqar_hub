import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'language_card_widget.dart';

class LanguageOptionsWidget extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onSelect;

  const LanguageOptionsWidget({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppAnimations.combined(
          type: CombineType.fadeSlide,
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 350),
          direction: SlideDirection.up,
          curve: Curves.easeOutCubic,
          child: LanguageCardWidget(
            language: 'العربية',
            subtitle: 'Arabic',
            isSelected: selectedCode == 'ar',
            onTap: () => onSelect('ar'),
          ),
        ),

        SizedBox(height: context.r(16)),

        AppAnimations.combined(
          type: CombineType.fadeSlide,
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 450),
          direction: SlideDirection.up,
          curve: Curves.easeOutCubic,
          child: LanguageCardWidget(
            language: 'English',
            subtitle: 'الإنجليزية',
            isSelected: selectedCode == 'en',
            onTap: () => onSelect('en'),
          ),
        ),
      ],
    );
  }
}
