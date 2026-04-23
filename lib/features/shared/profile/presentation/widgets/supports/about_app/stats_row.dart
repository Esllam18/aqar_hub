// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _StatsData {
  final int listings;
  final int users;

  const _StatsData({required this.listings, required this.users});
}

// ── Widget ────────────────────────────────────────────────────────────────────

class StatsRow extends StatefulWidget {
  const StatsRow({super.key});

  @override
  State<StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<StatsRow> {
  _StatsData? _data;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = Supabase.instance.client;

      final results = await Future.wait([
        db.from('properties').select().count(CountOption.exact),
        db.from('profiles').select().count(CountOption.exact),
      ]);

      final listingsCount = results[0].count;
      final usersCount = results[1].count;

      if (mounted) {
        setState(() {
          _data = _StatsData(listings: listingsCount, users: usersCount);
        });
      }
    } catch (_) {
      // Non-fatal — show placeholder values on failure
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M+';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K+';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        Icons.home_work_rounded,
        _data != null ? _formatCount(_data!.listings) : '...',
        'about_stat_listings',
      ),
      (
        Icons.people_rounded,
        _data != null ? _formatCount(_data!.users) : '...',
        'about_stat_users',
      ),
      (Icons.star_rounded, '4.8', 'about_stat_rating'),
    ];

    return Row(
      children: stats.map((s) {
        final (icon, value, key) = s;
        return Expanded(
          child: Container(
            margin: context.rSymmetric(horizontal: 4),
            padding: context.rSymmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: context.r(22)),
                SizedBox(height: context.r(6)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Text(
                  key.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
