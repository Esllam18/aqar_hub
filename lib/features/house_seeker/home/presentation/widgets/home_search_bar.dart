// lib/features/house_seeker/home/presentation/widgets/home_search_bar.dart

import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/search/presentation/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  void _openSearch(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const SearchView(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.combined(
      type: CombineType.fadeSlide,
      duration: const Duration(milliseconds: 450),
      delay: const Duration(milliseconds: 80),
      child: Padding(
        padding: context.rOnly(left: 16, right: 16, top: 12, bottom: 4),
        child: GestureDetector(
          onTap: () => _openSearch(context),
          child: Container(
            padding: context.rSymmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: context.r(16),
                  offset: Offset(0, context.r(4)),
                ),
              ],
            ),
            child: Row(
              children: [
                // AI icon — matches app primary color
                Container(
                  width: context.r(38),
                  height: context.r(38),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(context.r(10)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: context.r(8),
                        offset: Offset(0, context.r(3)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: context.r(18),
                  ),
                ),

                SizedBox(width: context.r(12)),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home_search_hint'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(13),
                          color: Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(height: context.r(2)),
                      Text(
                        'home_search_sub'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(10),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // AI label badge
                Container(
                  padding: context.rSymmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(context.r(8)),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        size: context.r(11),
                        color: AppColors.primary,
                      ),
                      SizedBox(width: context.r(3)),
                      Text(
                        'AI',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
