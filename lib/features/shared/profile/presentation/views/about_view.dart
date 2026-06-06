import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/contact_us_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/help_center_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_section_label.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_build_info_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_developer_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_info_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_shortcut_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_stats_row.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/about_tech_stack_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then(
      (info) => setState(() => _version = info.version),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient SliverAppBar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: context.r(220),
            pinned: true,
            backgroundColor: const Color(0xFF1B4B8C),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: context.r(24)),
                      // Logo ring with subtle shimmer border
                      Container(
                        width: context.r(80),
                        height: context.r(80),
                        padding: context.rAll(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          AppImages.logo,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(height: context.r(12)),
                      Text(
                        'app_name'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(22),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: context.r(6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HeaderChip(
                            icon: Icons.tag_rounded,
                            label: 'v$_version',
                          ),
                          SizedBox(width: context.r(8)),
                          const _HeaderChip(
                            icon: Icons.smartphone_rounded,
                            label: 'Android & iOS',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: context.rAll(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: context.r(4)),

                // ── Stats row ──────────────────────────────────────────
                const AboutStatsRow(),
                SizedBox(height: context.r(24)),

                // ── App info section ───────────────────────────────────
                HelpSectionLabel(label: 'about_section_info'.tr(context)),
                SizedBox(height: context.r(12)),
                const AboutInfoCard(
                  icon: Icons.info_outline_rounded,
                  gradient: [Color(0xFF6A1B9A), Color(0xFF7E57C2)],
                  titleKey: 'about_desc_title',
                  bodyKey: 'about_desc_body',
                ),
                SizedBox(height: context.r(10)),
                const AboutInfoCard(
                  icon: Icons.verified_rounded,
                  gradient: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  titleKey: 'about_mission_title',
                  bodyKey: 'about_mission_body',
                ),
                SizedBox(height: context.r(10)),
                const AboutInfoCard(
                  icon: Icons.shield_outlined,
                  gradient: [Color(0xFF0277BD), Color(0xFF039BE5)],
                  titleKey: 'about_privacy_title',
                  bodyKey: 'about_privacy_body',
                ),

                SizedBox(height: context.r(24)),

                // ── Tech stack ─────────────────────────────────────────
                HelpSectionLabel(label: 'about_section_tech'.tr(context)),
                SizedBox(height: context.r(12)),
                const AboutTechStackCard(),

                SizedBox(height: context.r(24)),

                // ── Developer card ─────────────────────────────────────
                HelpSectionLabel(label: 'about_section_team'.tr(context)),
                SizedBox(height: context.r(12)),
                const AboutDeveloperCard(),

                SizedBox(height: context.r(24)),

                // ── Shortcut cards (Help & Contact) ────────────────────
                HelpSectionLabel(label: 'about_section_support'.tr(context)),
                SizedBox(height: context.r(12)),
                Row(
                  children: [
                    Expanded(
                      child: AboutShortcutCard(
                        icon: Icons.help_outline_rounded,
                        gradient: const [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                        titleKey: 'about_shortcut_help_title',
                        subtitleKey: 'about_shortcut_help_sub',
                        onTap: () => Navigation.to(const HelpCenterView()),
                      ),
                    ),
                    SizedBox(width: context.r(12)),
                    Expanded(
                      child: AboutShortcutCard(
                        icon: Icons.headset_mic_rounded,
                        gradient: const [Color(0xFF0277BD), Color(0xFF039BE5)],
                        titleKey: 'about_shortcut_contact_title',
                        subtitleKey: 'about_shortcut_contact_sub',
                        onTap: () => Navigation.to(const ContactUsView()),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.r(24)),

                // ── Build info ─────────────────────────────────────────
                HelpSectionLabel(label: 'about_section_build'.tr(context)),
                SizedBox(height: context.r(12)),
                AboutBuildInfoCard(version: _version),

                SizedBox(height: context.r(100)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small chip in the app bar header ──────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: context.r(11)),
          SizedBox(width: context.r(4)),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
