import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/faq_tile_and_states.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/quick_contact_btn.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/report_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/secation_label.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient SliverAppBar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: context.r(160),
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
                    colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: context.r(32)),
                      Container(
                        width: context.r(56),
                        height: context.r(56),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: context.r(26),
                        ),
                      ),
                      SizedBox(height: context.r(10)),
                      Text(
                        'profile_menu_help'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'help_subtitle'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: Colors.white.withValues(alpha: 0.75),
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

                // ── Quick contact ──────────────────────────────────────
                SectionLabel(label: 'help_section_contact'.tr(context)),
                SizedBox(height: context.r(10)),
                Row(
                  children: [
                    Expanded(
                      child: QuickContactBtn(
                        icon: Icons.phone_rounded,
                        label: 'contact_phone_title'.tr(context),
                        color: AppColors.primary,
                        onTap: () => _launch('tel:+20123456789'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: QuickContactBtn(
                        icon: Icons.chat_rounded,
                        label: 'contact_chat_title'.tr(context),
                        color: const Color(0xFF43A047),
                        onTap: () => _launch('https://wa.me/20123456789'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: QuickContactBtn(
                        icon: Icons.email_rounded,
                        label: 'contact_email_title'.tr(context),
                        color: const Color(0xFF039BE5),
                        onTap: () => _launch('mailto:support@aqarhub.com'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.r(24)),

                // ── FAQ ────────────────────────────────────────────────
                SectionLabel(label: 'help_section_faq'.tr(context)),
                SizedBox(height: context.r(10)),
                const FaqTile(questionKey: 'help_q1', answerKey: 'help_a1'),
                const FaqTile(questionKey: 'help_q2', answerKey: 'help_a2'),
                const FaqTile(questionKey: 'help_q3', answerKey: 'help_a3'),
                const FaqTile(questionKey: 'help_q4', answerKey: 'help_a4'),

                SizedBox(height: context.r(24)),

                // ── Report ─────────────────────────────────────────────
                SectionLabel(label: 'help_section_report'.tr(context)),
                SizedBox(height: context.r(10)),
                const ReportCard(),

                SizedBox(height: context.r(80)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
