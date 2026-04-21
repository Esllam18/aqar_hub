// lib/features/splash/widgets/splash_content.dart

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({super.key});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _barFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _barFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Gradient background ──────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B2D5E), Color(0xFF243772), Color(0xFF1B2D5E)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // ── Subtle circle decorations ────────────────────────────────────
        Positioned(
          top: -context.r(80),
          right: -context.r(60),
          child: Container(
            width: context.r(260),
            height: context.r(260),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          bottom: -context.r(100),
          left: -context.r(70),
          child: Container(
            width: context.r(300),
            height: context.r(300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          top: context.r(160),
          left: -context.r(40),
          child: Container(
            width: context.r(120),
            height: context.r(120),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),

        // ── Main content ─────────────────────────────────────────────────
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with glow
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: context.r(130),
                    height: context.r(130),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.12),
                          blurRadius: context.r(40),
                          spreadRadius: context.r(8),
                        ),
                      ],
                    ),
                    padding: context.rAll(24),
                    child: SvgPicture.asset(
                      AppImages.logo,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.r(28)),

              // App name
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      Text(
                        'عقار هاب',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(36),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AqarHub',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.65),
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.r(14)),

              // Tagline
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Text(
                    'اكتشف منزلك المستقبلي',
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(13),
                      color: Colors.white.withOpacity(0.55),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Loading bar at bottom ─────────────────────────────────────────
        Positioned(
          bottom: context.r(60),
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _barFade,
            child: Column(
              children: [
                SizedBox(
                  width: context.w(0.38),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(4)),
                    child: LinearProgressIndicator(
                      minHeight: context.r(2.5),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.r(12)),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
