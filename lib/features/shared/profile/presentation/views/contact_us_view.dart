// lib/features/shared/profile/presentation/views/contact_us_view.dart
//
// Fully redesigned Contact Us with real contact info:
// Phone: 01155374945 | Instagram: esllam_x3 | Email: esllam.maherr@gmail.com

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  static const _phone = '01155374945';
  static const _email = 'esllam.maherr@gmail.com';
  static const _instagram = 'esllam_x3';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ${'contact_copied'.tr(context)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient header
          SliverAppBar(
            expandedHeight: context.r(160),
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: context.r(20)),
              onPressed: Navigation.back,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4B8C), Color(0xFF1E88E5)],
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
                        width: context.r(60),
                        height: context.r(60),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: context.r(28)),
                      ),
                      SizedBox(height: context.r(10)),
                      Text('contact_title'.tr(context),
                          style: GoogleFonts.cairo(
                              fontSize: context.sp(20),
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('contact_subtitle'.tr(context),
                          style: GoogleFonts.tajawal(
                              fontSize: context.sp(12),
                              color: Colors.white.withValues(alpha: 0.75))),
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

                // ── Direct contact ───────────────────────────────────────
                _SectionLabel(label: 'contact_channels_title'.tr(context)),
                SizedBox(height: context.r(12)),

                // Phone — Call + WhatsApp + Telegram in one card
                _ContactCard(
                  icon: Icons.phone_rounded,
                  gradient: const [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  title: 'contact_phone_title'.tr(context),
                  value: _phone,
                  badge: 'contact_badge_instant'.tr(context),
                  badgeColor: const Color(0xFF43A047),
                  onTap: () => _launch('tel:+20$_phone'),
                  onLongPress: () =>
                      _copyToClipboard(context, _phone, 'contact_phone_title'.tr(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniAction(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        tooltip: 'WhatsApp',
                        onTap: () => _launch('https://wa.me/20$_phone'),
                      ),
                      SizedBox(width: context.r(6)),
                      _MiniAction(
                        icon: Icons.telegram,
                        color: const Color(0xFF0088CC),
                        tooltip: 'Telegram',
                        onTap: () => _launch('https://t.me/+20$_phone'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.r(10)),

                // Email
                _ContactCard(
                  icon: Icons.email_rounded,
                  gradient: const [Color(0xFF0277BD), Color(0xFF039BE5)],
                  title: 'contact_email_title'.tr(context),
                  value: _email,
                  badge: 'contact_badge_24h'.tr(context),
                  badgeColor: const Color(0xFF039BE5),
                  onTap: () => _launch('mailto:$_email'),
                  onLongPress: () =>
                      _copyToClipboard(context, _email, 'contact_email_title'.tr(context)),
                ),
                SizedBox(height: context.r(10)),

                // Instagram
                _ContactCard(
                  icon: Icons.photo_camera_rounded,
                  gradient: const [Color(0xFFE91E63), Color(0xFFAD1457)],
                  title: 'Instagram',
                  value: '@$_instagram',
                  badge: 'contact_badge_dm'.tr(context),
                  badgeColor: const Color(0xFFE91E63),
                  onTap: () =>
                      _launch('https://instagram.com/$_instagram'),
                  onLongPress: () =>
                      _copyToClipboard(context, _instagram, 'Instagram'),
                ),

                SizedBox(height: context.r(24)),

                // ── Social quick links ────────────────────────────────────
                _SectionLabel(label: 'contact_social_title'.tr(context)),
                SizedBox(height: context.r(12)),
                Row(
                  children: [
                    Expanded(
                      child: _SocialBtn(
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () => _launch('https://wa.me/20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: _SocialBtn(
                        icon: Icons.telegram,
                        label: 'Telegram',
                        color: const Color(0xFF0088CC),
                        onTap: () => _launch('https://t.me/+20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: _SocialBtn(
                        icon: Icons.photo_camera_rounded,
                        label: 'Instagram',
                        color: const Color(0xFFE91E63),
                        onTap: () =>
                            _launch('https://instagram.com/$_instagram'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.r(80)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget? trailing;

  const _ContactCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
    required this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(48),
              height: context.r(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
              child: Icon(icon, color: Colors.white, size: context.r(22)),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.tajawal(
                          fontSize: context.sp(11),
                          color: Colors.grey.shade500)),
                  Text(value,
                      style: GoogleFonts.cairo(
                          fontSize: context.sp(13.5),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B2D5E))),
                  SizedBox(height: context.r(4)),
                  Container(
                    padding: context.rSymmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(context.r(6)),
                    ),
                    child: Text(badge,
                        style: GoogleFonts.tajawal(
                            fontSize: context.sp(10),
                            color: badgeColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Mini action button ────────────────────────────────────────────────────────

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: context.r(36),
          height: context.r(36),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: context.r(18)),
        ),
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.rSymmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: context.r(24)),
            SizedBox(height: context.r(6)),
            Text(label,
                style: GoogleFonts.tajawal(
                    fontSize: context.sp(11),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: context.sp(13.5),
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B2D5E),
      ),
    );
  }
}
