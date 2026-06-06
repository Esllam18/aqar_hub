// ignore_for_file: unused_element

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_content.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_topic_model.dart';

import 'package:aqar_hub/features/shared/profile/presentation/views/contact_us_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/help_faq_list_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/help_guide_detail_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/help_category_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/help_faq_tile.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_gradient_app_bar.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_quick_contact_btn.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_section_label.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatelessWidget {
  final AppRole role;

  const HelpCenterView({super.key, this.role = AppRole.seeker});

  // ── Contact constants ──────────────────────────────────────────────────────
  static const _phone = '01155374945';
  static const _email = 'esllam.maherr@gmail.com';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  HelpAudience get _audience =>
      role == AppRole.owner ? HelpAudience.owner : HelpAudience.seeker;

  List<({String key, HelpGuide guide})> get _popularFaqs {
    // Show 3 most relevant FAQs on the home screen
    return HelpContent.allFaqs
        .where((f) => f.audience == HelpAudience.all || f.audience == _audience)
        .take(3)
        .map((f) => (key: f.questionKey, guide: HelpContent.gettingStarted))
        .toList();
  }

  List<FaqItem> get _previewFaqs => HelpContent.allFaqs
      .where((f) => f.audience == HelpAudience.all || f.audience == _audience)
      .take(3)
      .toList();

  @override
  Widget build(BuildContext context) {
    final categories = role == AppRole.owner
        ? HelpContent.ownerCategories
        : HelpContent.seekerCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient app bar ─────────────────────────────────────────
          HelpGradientAppBar(
            headerIcon: Icons.support_agent_rounded,
            title: 'profile_menu_help'.tr(context),
            subtitle: 'help_subtitle'.tr(context),
            gradientColors: const [Color(0xFF1B4B8C), Color(0xFF26A69A)],
            expandedHeight: 185,
          ),

          SliverPadding(
            padding: context.rAll(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: context.r(4)),

                // ── Role banner ────────────────────────────────────────
                _RoleBanner(role: role),
                SizedBox(height: context.r(20)),

                // ── Quick contact ──────────────────────────────────────
                HelpSectionLabel(label: 'help_section_contact'.tr(context)),
                SizedBox(height: context.r(12)),
                Row(
                  children: [
                    Expanded(
                      child: HelpQuickContactBtn(
                        icon: Icons.phone_rounded,
                        label: 'contact_phone_title'.tr(context),
                        color: AppColors.primary,
                        onTap: () => _launch('tel:+20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: HelpQuickContactBtn(
                        icon: Icons.chat_rounded,
                        label: 'contact_chat_title'.tr(context),
                        color: const Color(0xFF25D366),
                        onTap: () => _launch('https://wa.me/20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: HelpQuickContactBtn(
                        icon: Icons.email_rounded,
                        label: 'contact_email_title'.tr(context),
                        color: const Color(0xFF039BE5),
                        onTap: () => _launch('mailto:$_email'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.r(24)),

                // ── How-to guides ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HelpSectionLabel(label: 'help_section_guides'.tr(context)),
                  ],
                ),

                // 2-column grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: context.r(12),
                    crossAxisSpacing: context.r(12),
                    childAspectRatio: 0.82,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return HelpCategoryCard(
                      icon: cat.icon,
                      gradient: cat.gradient,
                      title: cat.titleKey.tr(context),
                      subtitle: cat.subtitleKey.tr(context),
                      onTap: () {
                        final guide = HelpContent.guideForCategory(
                          cat.titleKey,
                        );
                        if (guide != null) {
                          Navigation.to(HelpGuideDetailView(guide: guide));
                        }
                      },
                    );
                  },
                ),

                SizedBox(height: context.r(24)),

                // ── Popular FAQs preview ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HelpSectionLabel(label: 'help_section_faq'.tr(context)),
                    GestureDetector(
                      onTap: () =>
                          Navigation.to(HelpFaqListView(audience: _audience)),
                      child: Container(
                        padding: context.rSymmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(context.r(20)),
                        ),
                        child: Text(
                          'help_see_all'.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.r(12)),
                ..._previewFaqs.map(
                  (f) => HelpFaqTile(
                    questionKey: f.questionKey,
                    answerKey: f.answerKey,
                  ),
                ),

                SizedBox(height: context.r(24)),

                // ── Contact us & report ────────────────────────────────
                HelpSectionLabel(label: 'help_section_report'.tr(context)),
                SizedBox(height: context.r(12)),
                _ReportCard(
                  onTap: () => _launch(
                    'mailto:$_email'
                    '?subject=AqarHub%20%E2%80%94%20Report%20%2F%20Bug'
                    '&body=Describe%20your%20issue%20here...',
                  ),
                ),
                SizedBox(height: context.r(10)),
                _ContactUsCard(
                  onTap: () => Navigation.to(const ContactUsView()),
                ),

                SizedBox(height: context.r(100)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role banner ───────────────────────────────────────────────────────────────

class _RoleBanner extends StatelessWidget {
  final AppRole role;

  const _RoleBanner({required this.role});

  @override
  Widget build(BuildContext context) {
    final isOwner = role == AppRole.owner;
    final gradient = isOwner
        ? const [Color(0xFF6A1B9A), Color(0xFFAB47BC)]
        : const [Color(0xFF1B4B8C), Color(0xFF42A5F5)];
    final icon = isOwner ? Icons.home_work_rounded : Icons.search_rounded;
    final titleKey = isOwner
        ? 'help_banner_owner_title'
        : 'help_banner_seeker_title';
    final bodyKey = isOwner
        ? 'help_banner_owner_body'
        : 'help_banner_seeker_body';

    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.r(52),
            height: context.r(52),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Icon(icon, color: Colors.white, size: context.r(26)),
          ),
          SizedBox(width: context.r(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.r(3)),
                Text(
                  bodyKey.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(12),
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report card ───────────────────────────────────────────────────────────────

class _ReportCard extends StatefulWidget {
  final Future<void> Function() onTap;

  const _ReportCard({required this.onTap});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _loading = false;

  Future<void> _handle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _handle,
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(46),
              height: context.r(46),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(13)),
              ),
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(context.r(12)),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.flag_outlined,
                      color: Colors.white,
                      size: context.r(20),
                    ),
            ),
            SizedBox(width: context.r(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'help_report_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  Text(
                    'help_report_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: context.r(13),
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact us card ───────────────────────────────────────────────────────────

class _ContactUsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ContactUsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(46),
              height: context.r(46),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(13)),
              ),
              child: Icon(
                Icons.headset_mic_rounded,
                color: Colors.white,
                size: context.r(20),
              ),
            ),
            SizedBox(width: context.r(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'contact_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: context.r(13),
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
