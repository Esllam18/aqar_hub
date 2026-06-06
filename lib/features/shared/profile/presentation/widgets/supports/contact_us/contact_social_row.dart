// ignore_for_file: unused_element

import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// A row of tappable social platform pills (WhatsApp, Telegram, Instagram).
class ContactSocialRow extends StatelessWidget {
  const ContactSocialRow({super.key});

  static const _phone = '01155374945';
  static const _instagram = 'esllam_x3';

  // ✅ FIXED: removed canLaunchUrl() guard
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
    final socials = [
      (
        image: const AssetImage(AppImages.whatsapp),
        color: const Color(0xFF25D366),
        label: 'WhatsApp',
        url: 'https://wa.me/20$_phone',
      ),
      (
        image: const AssetImage(AppImages.telegram),
        color: const Color(0xFF0088CC),
        label: 'Telegram',
        url: 'https://t.me/+20$_phone',
      ),
      (
        image: const AssetImage(AppImages.instagram),
        color: const Color(0xFFE91E63),
        label: 'Instagram',
        url: 'https://instagram.com/$_instagram',
      ),
    ];

    return Row(
      children: socials.map((s) {
        return Expanded(
          child: _SocialBtn(
            image: s.image,
            color: s.color,
            label: s.label,
            url: s.url,
          ),
        );
      }).toList(),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final ImageProvider? image;
  final Color color;
  final String label;
  final String url;

  const _SocialBtn({
    required this.image,
    required this.color,
    required this.label,
    required this.url,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _loading = false;

  Future<void> _handle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(widget.url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _handle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: context.rSymmetric(horizontal: 4),
        padding: context.rSymmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _loading ? 0.05 : 0.13),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loading
                ? SizedBox(
                    width: context.r(22),
                    height: context.r(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.color,
                    ),
                  )
                : Image(
                    image: widget.image!,
                    width: context.r(25),
                    height: context.r(25),
                  ),
            SizedBox(height: context.r(6)),
            Text(
              widget.label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
