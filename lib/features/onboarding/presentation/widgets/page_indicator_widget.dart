import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (i) => _Dot(isActive: i == currentPage, context: context),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  final BuildContext context;

  const _Dot({required this.isActive, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(horizontal: context.r(4)),
      width: isActive ? context.r(28) : context.r(8),
      height: context.r(8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
    );
  }
}
