import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: context.r(3),
      ),
    ),
  );
}
