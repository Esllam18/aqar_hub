// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/view/add_property_view.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerEmptyState extends StatelessWidget {
  /// Called when user taps "Add Property". Pass null to hide the button.
  final VoidCallback? onAddTap;

  /// When true: the list is empty because of a filter, not because
  /// the owner has no properties.
  final bool isFilterEmpty;

  /// Which filter produced the empty result (used for messaging).
  final OwnerHomeFilter? filterName;

  const OwnerEmptyState({
    super.key,
    this.onAddTap,
    this.isFilterEmpty = false,
    this.filterName,
  });

  @override
  Widget build(BuildContext context) {
    return isFilterEmpty
        ? _FilterEmptyState(filterName: filterName)
        : _NoPropertiesState(onAddTap: onAddTap);
  }
}

// ── No properties at all ──────────────────────────────────────────────────────

class _NoPropertiesState extends StatelessWidget {
  final VoidCallback? onAddTap;
  const _NoPropertiesState({this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: context.rSymmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Hero illustration ────────────────────────────────────────
            _PropertyIllustration(),
            SizedBox(height: context.r(28)),

            // ── Headline ─────────────────────────────────────────────────
            Text(
              'owner_empty_title'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: context.sp(22),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
                height: 1.3,
              ),
            ),
            SizedBox(height: context.r(10)),
            Text(
              'owner_empty_subtitle'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13.5),
                color: Colors.grey.shade600,
                height: 1.65,
              ),
            ),

            SizedBox(height: context.r(28)),

            // ── Feature pills ─────────────────────────────────────────────
            Wrap(
              spacing: context.r(8),
              runSpacing: context.r(8),
              alignment: WrapAlignment.center,
              children: const [
                _FeaturePill(
                  icon: Icons.visibility_rounded,
                  labelKey: 'owner_empty_feat_visibility',
                  color: AppColors.primary,
                ),
                _FeaturePill(
                  icon: Icons.people_rounded,
                  labelKey: 'owner_empty_feat_reach',
                  color: AppColors.success,
                ),
                _FeaturePill(
                  icon: Icons.smart_toy_rounded,
                  labelKey: 'owner_empty_feat_ai',
                  color: Color(0xFF7C3AED),
                ),
              ],
            ),

            SizedBox(height: context.r(32)),

            // ── Primary CTA ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    onAddTap ?? () => Navigation.to(const AddPropertyView()),
                icon: Icon(Icons.add_rounded, size: context.r(20)),
                label: Text(
                  'owner_add_property'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(double.infinity, context.r(52)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(16)),
                  ),
                ),
              ),
            ),

            SizedBox(height: context.r(12)),

            // ── Secondary hint ────────────────────────────────────────────
            Text(
              'owner_empty_hint'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11.5),
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom building illustration drawn with CustomPaint ───────────────────────

class _PropertyIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = context.r(200);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BuildingPainter()),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Background circle ────────────────────────────────────────────────
    final bgPaint = Paint()
      ..color = const Color(0xFFEEF3FC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    // ── Shadow under building ────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = const Color(0x18163F7A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.82),
        width: w * 0.58,
        height: h * 0.06,
      ),
      shadowPaint,
    );

    // ── Main building body ───────────────────────────────────────────────
    final bodyPaint = Paint()
      ..color = const Color(0xFF1B4D9B)
      ..style = PaintingStyle.fill;
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.25, h * 0.32, w * 0.50, h * 0.46),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── Roof triangle ─────────────────────────────────────────────────────
    final roofPaint = Paint()
      ..color = const Color(0xFF163880)
      ..style = PaintingStyle.fill;
    final roofPath = Path()
      ..moveTo(w * 0.22, h * 0.33)
      ..lineTo(w * 0.50, h * 0.14)
      ..lineTo(w * 0.78, h * 0.33)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // ── Side building (shorter) ───────────────────────────────────────────
    final sidePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    final sideRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.62, h * 0.44, w * 0.18, h * 0.34),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
    );
    canvas.drawRRect(sideRect, sidePaint);

    // Small side roof
    final sideRoofPath = Path()
      ..moveTo(w * 0.60, h * 0.45)
      ..lineTo(w * 0.71, h * 0.36)
      ..lineTo(w * 0.82, h * 0.45)
      ..close();
    canvas.drawPath(sideRoofPath, Paint()..color = const Color(0xFF1E4FC0));

    // ── Windows on main building ──────────────────────────────────────────
    final winPaint = Paint()
      ..color = const Color(0xFFBDD7FF)
      ..style = PaintingStyle.fill;
    final winLitPaint = Paint()
      ..color = const Color(0xFFFFE082)
      ..style = PaintingStyle.fill;

    final windows = [
      // Row 1
      Rect.fromLTWH(w * 0.31, h * 0.38, w * 0.10, h * 0.10),
      Rect.fromLTWH(w * 0.45, h * 0.38, w * 0.10, h * 0.10),
      Rect.fromLTWH(w * 0.59, h * 0.38, w * 0.10, h * 0.10),
      // Row 2
      Rect.fromLTWH(w * 0.31, h * 0.52, w * 0.10, h * 0.10),
      Rect.fromLTWH(w * 0.45, h * 0.52, w * 0.10, h * 0.10),
      Rect.fromLTWH(w * 0.59, h * 0.52, w * 0.10, h * 0.10),
    ];

    for (var i = 0; i < windows.length; i++) {
      final rr = RRect.fromRectAndRadius(windows[i], const Radius.circular(3));
      canvas.drawRRect(rr, i == 1 || i == 4 ? winLitPaint : winPaint);
    }

    // ── Door ──────────────────────────────────────────────────────────────
    final doorPaint = Paint()
      ..color = const Color(0xFF1A3A7A)
      ..style = PaintingStyle.fill;
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.43, h * 0.63, w * 0.14, h * 0.15),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(doorRect, doorPaint);

    // ── Small clouds ──────────────────────────────────────────────────────
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.80)
      ..style = PaintingStyle.fill;
    _drawCloud(canvas, Offset(w * 0.14, h * 0.22), w * 0.10, cloudPaint);
    _drawCloud(canvas, Offset(w * 0.75, h * 0.18), w * 0.08, cloudPaint);

    // ── Ground line ────────────────────────────────────────────────────────
    final groundPaint = Paint()
      ..color = const Color(0xFFD0DEF5)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(w * 0.15, h * 0.785),
      Offset(w * 0.85, h * 0.785),
      groundPaint,
    );

    // ── Trees ────────────────────────────────────────────────────────────
    _drawTree(canvas, Offset(w * 0.18, h * 0.76), context: size);
    _drawTree(canvas, Offset(w * 0.82, h * 0.76), context: size);
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(
      Offset(center.dx + r * 0.7, center.dy + r * 0.15),
      r * 0.75,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx - r * 0.5, center.dy + r * 0.2),
      r * 0.65,
      paint,
    );
  }

  void _drawTree(Canvas canvas, Offset base, {required Size context}) {
    final trunkPaint = Paint()..color = const Color(0xFF8B5E3C);
    final leafPaint = Paint()..color = const Color(0xFF34A853);
    final w = context.width;
    final h = context.height;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy + h * 0.01),
        width: w * 0.020,
        height: h * 0.04,
      ),
      trunkPaint,
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy - h * 0.02),
      w * 0.040,
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(_BuildingPainter old) => false;
}

// ── Feature pill ──────────────────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.labelKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.r(13), color: color),
          SizedBox(width: context.r(6)),
          Text(
            labelKey.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter empty state ────────────────────────────────────────────────────────

class _FilterEmptyState extends StatelessWidget {
  final OwnerHomeFilter? filterName;
  const _FilterEmptyState({this.filterName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.rSymmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(80),
              height: context.r(80),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_off_rounded,
                size: context.r(36),
                color: AppColors.primary.withOpacity(0.60),
              ),
            ),
            SizedBox(height: context.r(20)),
            Text(
              'owner_filter_empty_title'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
              ),
            ),
            SizedBox(height: context.r(8)),
            Text(
              'owner_filter_empty_subtitle'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
                height: 1.55,
              ),
            ),
            SizedBox(height: context.r(100)),
          ],
        ),
      ),
    );
  }
}
