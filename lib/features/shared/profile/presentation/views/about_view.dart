import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/buid_info_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/info_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/about_app/stats_row.dart';
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
          // ── Gradient SliverAppBar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: context.r(200),
            pinned: true,
            backgroundColor: AppColors.primary,
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
                    colors: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: context.r(20)),
                      Container(
                        width: context.r(72),
                        height: context.r(72),
                        padding: context.rAll(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          AppImages.logo,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(height: context.r(10)),
                      Text(
                        'app_name'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: context.rOnly(top: 4),
                        padding: context.rSymmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(context.r(20)),
                        ),
                        child: Text(
                          'v$_version',
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                const StatsRow(),
                SizedBox(height: context.r(20)),

                // ── Info cards ─────────────────────────────────────────
                const InfoCard(
                  icon: Icons.info_outline_rounded,
                  gradient: [Color(0xFF6A1B9A), Color(0xFF7E57C2)],
                  titleKey: 'about_desc_title',
                  bodyKey: 'about_desc_body',
                ),
                SizedBox(height: context.r(10)),
                const InfoCard(
                  icon: Icons.verified_rounded,
                  gradient: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  titleKey: 'about_mission_title',
                  bodyKey: 'about_mission_body',
                ),
                SizedBox(height: context.r(10)),
                const InfoCard(
                  icon: Icons.shield_outlined,
                  gradient: [Color(0xFF0277BD), Color(0xFF039BE5)],
                  titleKey: 'about_privacy_title',
                  bodyKey: 'about_privacy_body',
                ),

                SizedBox(height: context.r(20)),

                // ── Version & build info ───────────────────────────────
                BuildInfoCard(version: _version),

                SizedBox(height: context.r(80)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
