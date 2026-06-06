import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_topic_model.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/help_faq_list_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/contact_us/contact_channel_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/contact_us/contact_hours_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/contact_us/contact_social_row.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_gradient_app_bar.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/shared/help_section_label.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  static const _phone = '01155374945';
  static const _email = 'esllam.maherr@gmail.com';
  static const _instagram = 'esllam_x3';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ─────────────────────────────────────────────────
          HelpGradientAppBar(
            headerIcon: Icons.headset_mic_rounded,
            title: 'contact_title'.tr(context),
            subtitle: 'contact_subtitle'.tr(context),
            gradientColors: const [Color(0xFF1B4B8C), Color(0xFF1E88E5)],
          ),

          SliverPadding(
            padding: context.rAll(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: context.r(4)),

                // ── Response time strip ────────────────────────────────
                _ResponseTimeBanner(),
                SizedBox(height: context.r(20)),

                // ── Direct channels ───────────────────────────────────
                HelpSectionLabel(label: 'contact_channels_title'.tr(context)),
                SizedBox(height: context.r(12)),

                // Phone
                ContactChannelCard(
                  image: const AssetImage(AppImages.phone),
                  gradient: const [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  titleKey: 'contact_phone_title',
                  value: '+20 $_phone',
                  badgeText: 'contact_badge_instant'.tr(context),
                  badgeColor: const Color(0xFF16A34A),
                  onTap: () => _launch('tel:+20$_phone'),
                  trailingActions: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContactMiniActionBtn(
                        image: const AssetImage(AppImages.whatsapp),
                        color: const Color(0xFF25D366),
                        tooltip: 'WhatsApp',
                        onTap: () => _launch('https://wa.me/20$_phone'),
                      ),
                      SizedBox(width: context.r(6)),
                      ContactMiniActionBtn(
                        image: const AssetImage(AppImages.telegram),
                        color: const Color(0xFF0088CC),
                        tooltip: 'Telegram',
                        onTap: () => _launch('https://t.me/+20$_phone'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.r(10)),

                // Email
                ContactChannelCard(
                  image: const AssetImage(AppImages.email),
                  gradient: const [Color(0xFF0277BD), Color(0xFF039BE5)],
                  titleKey: 'contact_email_title',
                  value: _email,
                  badgeText: 'contact_badge_24h'.tr(context),
                  badgeColor: const Color(0xFF039BE5),
                  onTap: () => _launch('mailto:$_email'),
                ),
                SizedBox(height: context.r(10)),

                // Instagram
                ContactChannelCard(
                  image: const AssetImage(AppImages.instagram),
                  gradient: const [Color(0xFFAD1457), Color(0xFFE91E63)],
                  titleKey: 'contact_instagram_title',
                  value: '@$_instagram',
                  badgeText: 'contact_badge_dm'.tr(context),
                  badgeColor: const Color(0xFFE91E63),
                  onTap: () => _launch('https://instagram.com/$_instagram'),
                ),

                SizedBox(height: context.r(24)),

                // ── Social quick links ─────────────────────────────────
                HelpSectionLabel(label: 'contact_social_title'.tr(context)),
                SizedBox(height: context.r(12)),
                const ContactSocialRow(),

                SizedBox(height: context.r(24)),

                // ── Working hours ─────────────────────────────────────
                HelpSectionLabel(
                  label: 'contact_hours_section_title'.tr(context),
                ),
                SizedBox(height: context.r(12)),
                const ContactHoursCard(),

                SizedBox(height: context.r(24)),

                // ── FAQ shortcut ──────────────────────────────────────
                const _FaqShortcutCard(audience: HelpAudience.all),

                SizedBox(height: context.r(100)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Response time banner ──────────────────────────────────────────────────────

class _ResponseTimeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4B8C).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(
          color: const Color(0xFF1B4B8C).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.r(36),
            height: context.r(36),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4B8C).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              color: const Color(0xFF1B4B8C),
              size: context.r(18),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Text(
              'contact_response_banner'.tr(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12.5),
                color: const Color(0xFF1B4B8C),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ shortcut card ─────────────────────────────────────────────────────────

class _FaqShortcutCard extends StatelessWidget {
  final HelpAudience audience;

  const _FaqShortcutCard({required this.audience});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigation.to(HelpFaqListView(audience: audience)),
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(context.r(18)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4B8C).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(48),
              height: context.r(48),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(context.r(13)),
              ),
              child: Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: context.r(24),
              ),
            ),
            SizedBox(width: context.r(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_faq_shortcut_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'contact_faq_shortcut_body'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: context.r(14),
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
