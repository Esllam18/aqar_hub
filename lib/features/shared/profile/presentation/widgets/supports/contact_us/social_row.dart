import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replace these URLs with your real social media pages
    final socials = [
      (Icons.facebook_rounded, const Color(0xFF1877F2), 'Facebook',
          'https://facebook.com'),
      (Icons.photo_camera_rounded, const Color(0xFFE91E63), 'Instagram',
          'https://instagram.com'),
      (Icons.telegram, const Color(0xFF0088CC), 'Telegram',
          'https://t.me/aqarhub'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: socials.map((s) {
        final (icon, color, label, url) = s;
        return Padding(
          padding: context.rOnly(right: 12, top: 12),
          child: GestureDetector(
            onTap: () => _launch(url),
            child: Container(
              padding: context.rAll(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.r(14)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: context.r(24)),
                  SizedBox(height: context.r(4)),
                  Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
