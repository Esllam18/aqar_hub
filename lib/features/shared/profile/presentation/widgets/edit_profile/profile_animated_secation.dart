import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';

class AnimationSecation extends StatelessWidget {
  final Widget child;
  final int delay;
  const AnimationSecation({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: context.rSymmetric(horizontal: 16),
      child: AppAnimations.combined(
        type: CombineType.fadeSlide,
        duration: const Duration(milliseconds: 400),
        delay: Duration(milliseconds: delay),
        child: child,
      ),
    ),
  );
}
