import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Tech item model ───────────────────────────────────────────────────────────

class _Tech {
  final String name;
  final String role;
  final Color color;
  final IconData icon;

  const _Tech({
    required this.name,
    required this.role,
    required this.color,
    required this.icon,
  });
}

// ── Widget ────────────────────────────────────────────────────────────────────

class AboutTechStackCard extends StatelessWidget {
  const AboutTechStackCard({super.key});

  static const _items = [
    _Tech(
      name: 'Flutter',
      role: 'about_tech_flutter',
      color: Color(0xFF027DFD),
      icon: Icons.phone_android_rounded,
    ),
    _Tech(
      name: 'Supabase',
      role: 'about_tech_supabase',
      color: Color(0xFF3ECF8E),
      icon: Icons.storage_rounded,
    ),
    _Tech(
      name: 'Firebase',
      role: 'about_tech_firebase',
      color: Color(0xFFFF8F00),
      icon: Icons.notifications_active_rounded,
    ),
    _Tech(
      name: 'Gemini AI',
      role: 'about_tech_gemini',
      color: Color(0xFF6A1B9A),
      icon: Icons.smart_toy_rounded,
    ),
    _Tech(
      name: 'BLoC',
      role: 'about_tech_bloc',
      color: Color(0xFF0277BD),
      icon: Icons.account_tree_rounded,
    ),
    _Tech(
      name: 'Clean Arch',
      role: 'about_tech_arch',
      color: Color(0xFF37474F),
      icon: Icons.layers_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: context.r(38),
                height: context.r(38),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.r(11)),
                ),
                child: Icon(
                  Icons.code_rounded,
                  color: Colors.white,
                  size: context.r(18),
                ),
              ),
              SizedBox(width: context.r(12)),
              Text(
                'about_tech_title'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(16)),
          Divider(height: 1, color: Colors.grey.shade100),
          // SizedBox(height: context.r(14)),
          // 2-column grid of tech badges
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: context.r(10),
              crossAxisSpacing: context.r(10),
              childAspectRatio: 2.8,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) => _TechBadge(tech: _items[i]),
          ),
        ],
      ),
    );
  }
}

// ── Individual tech badge ─────────────────────────────────────────────────────

class _TechBadge extends StatelessWidget {
  final _Tech tech;
  const _TechBadge({required this.tech});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tech.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: tech.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(tech.icon, color: tech.color, size: context.r(16)),
          SizedBox(width: context.r(7)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tech.name,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w800,
                    color: tech.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  tech.role.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
