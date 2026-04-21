import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesEmptyView extends StatefulWidget {
  const FavoritesEmptyView({super.key});

  @override
  State<FavoritesEmptyView> createState() => _FavoritesEmptyViewState();
}

class _FavoritesEmptyViewState extends State<FavoritesEmptyView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.rSymmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated heart icon ─────────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: context.r(110),
                height: context.r(110),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: context.r(52),
                    color: Colors.redAccent.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.r(24)),

            // ── Text ────────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Text(
                      'favorites_empty_title'.tr(context),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(18),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(height: context.r(8)),
                    Text(
                      'favorites_empty_subtitle'.tr(context),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(13),
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: context.r(28)),

                    // ── CTA button ─────────────────────────────────────
                    SizedBox(
                      width: context.r(200),
                      height: context.r(50),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigation.back(),
                        icon: Icon(
                          Icons.search_rounded,
                          size: context.r(18),
                          color: Colors.white,
                        ),
                        label: Text(
                          'favorites_btn_browse'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.r(14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
