import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable gradient SliverAppBar used on Help Center and Contact Us screens.
class HelpGradientAppBar extends StatelessWidget {
  final IconData headerIcon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final double expandedHeight;

  const HelpGradientAppBar({
    super.key,
    required this.headerIcon,
    required this.title,
    required this.subtitle,
    this.gradientColors = const [Color(0xFF1B4B8C), Color(0xFF26A69A)],
    this.expandedHeight = 170,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: context.r(expandedHeight),
      pinned: true,
      backgroundColor: gradientColors.first,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: context.r(20),
        ),
        onPressed: Navigation.back,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: context.r(28)),
                Container(
                  width: context.r(64),
                  height: context.r(64),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    headerIcon,
                    color: Colors.white,
                    size: context.r(30),
                  ),
                ),
                SizedBox(height: context.r(10)),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(12),
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
