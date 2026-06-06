import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A compact gradient shortcut card used to navigate to Help Center
/// or Contact Us directly from the About screen.
class AboutShortcutCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String subtitleKey;
  final VoidCallback onTap;

  const AboutShortcutCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.subtitleKey,
    required this.onTap,
  });

  @override
  State<AboutShortcutCard> createState() => _AboutShortcutCardState();
}

class _AboutShortcutCardState extends State<AboutShortcutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: context.rAll(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.r(18)),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.r(40),
                height: context.r(40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: context.r(20),
                ),
              ),
              SizedBox(height: context.r(12)),
              Text(
                widget.titleKey.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.r(3)),
              Text(
                widget.subtitleKey.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.r(10)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: context.r(26),
                  height: context.r(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: context.r(12),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
