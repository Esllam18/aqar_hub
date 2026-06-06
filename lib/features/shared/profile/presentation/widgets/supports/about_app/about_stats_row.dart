import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _StatsData {
  final int listings;
  final int users;
  const _StatsData({required this.listings, required this.users});
}

class AboutStatsRow extends StatefulWidget {
  const AboutStatsRow({super.key});

  @override
  State<AboutStatsRow> createState() => _AboutStatsRowState();
}

class _AboutStatsRowState extends State<AboutStatsRow> {
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
      if (mounted) {
        setState(
          () => _data = _StatsData(
            listings: results[0].count,
            users: results[1].count,
          ),
        );
      }
    } catch (_) {
      // Non-fatal — keep placeholder
    }
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M+';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K+';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        icon: Icons.home_work_rounded,
        value: _data != null ? _fmt(_data!.listings) : '...',
        labelKey: 'about_stat_listings',
        gradient: const [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
      ),
      (
        icon: Icons.people_rounded,
        value: _data != null ? _fmt(_data!.users) : '...',
        labelKey: 'about_stat_users',
        gradient: const [Color(0xFF1B5E20), Color(0xFF43A047)],
      ),
      (
        icon: Icons.star_rounded,
        value: '4.8',
        labelKey: 'about_stat_rating',
        gradient: const [Color(0xFFE65100), Color(0xFFFF8F00)],
      ),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: context.rSymmetric(horizontal: 4),
            padding: context.rSymmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(16)),
              boxShadow: [
                BoxShadow(
                  color: s.gradient.first.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: context.r(40),
                  height: context.r(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: s.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Icon(s.icon, color: Colors.white, size: context.r(20)),
                ),
                SizedBox(height: context.r(8)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    s.value,
                    key: ValueKey(s.value),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                ),
                SizedBox(height: context.r(2)),
                Text(
                  s.labelKey.tr(context),
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
