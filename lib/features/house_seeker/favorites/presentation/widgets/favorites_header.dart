import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesHeader extends StatelessWidget {
  final int count;
  const FavoritesHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4B8C), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.rOnly(left: 20, right: 20, top: 12, bottom: 20),
          child: Row(
            children: [
              // ── Back button ──────────────────────────────────────────

              // ── Title ────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'favorites_title'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(20),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (count > 0)
                      Text(
                        '$count ${'favorites_count_label'.tr(context)}',
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Heart decoration ─────────────────────────────────────
              Container(
                width: context.r(44),
                height: context.r(44),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent.shade100,
                  size: context.r(22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
