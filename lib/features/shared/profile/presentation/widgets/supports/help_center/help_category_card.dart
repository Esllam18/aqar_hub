import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A tappable category card shown in the 2-column grid on the Help Center home.
class HelpCategoryCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HelpCategoryCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<HelpCategoryCard> createState() => _HelpCategoryCardState();
}

class _HelpCategoryCardState extends State<HelpCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.r(48),
                height: context.r(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: context.r(22),
                ),
              ),
              SizedBox(height: context.r(12)),
              Text(
                widget.title,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13.5),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.r(4)),
              Text(
                widget.subtitle,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.r(7)),
              Center(
                child: Container(
                  width: context.r(40),
                  height: context.r(40),
                  decoration: BoxDecoration(
                    color: widget.gradient.first.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: context.r(20),
                    color: widget.gradient.first,
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
