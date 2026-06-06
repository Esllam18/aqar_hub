import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperCard extends StatelessWidget {
  const AboutDeveloperCard({super.key});

  static const _github = 'https://github.com/Esllam18';
  // ✅ UPDATED LinkedIn URL
  static const _linkedin = 'https://www.linkedin.com/in/eslam-maher-b99839255';
  static const _email = 'esllam.maherr@gmail.com';

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
    return Container(
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4B8C).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar + name row ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: context.r(58),
                height: context.r(58),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B4B8C).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(29)),
                    child: Image.asset(
                      AppImages.devImage,
                      width: context.r(56),
                      height: context.r(56),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.r(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eslam Maher',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(height: context.r(2)),
                    Text(
                      'about_dev_role'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(12),
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: context.r(6)),
                    Wrap(
                      spacing: context.r(6),
                      runSpacing: context.r(4),
                      children: const [
                        _SkillChip(
                          label: 'Mobile Developer',
                          color: Color(0xFF027DFD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: context.r(16)),
          Divider(height: 1, color: Colors.grey.shade100),
          SizedBox(height: context.r(14)),

          // ── Bio ────────────────────────────────────────────────────
          Text(
            'about_dev_bio'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade600,
              height: 1.7,
            ),
          ),

          SizedBox(height: context.r(16)),

          // ── Action buttons ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DevActionBtn(
                  image: Image.asset(
                    AppImages.github,
                    width: context.r(18),
                    height: context.r(18),
                  ),
                  label: 'GitHub',
                  color: const Color(0xFF24292E),
                  onTap: () => _launch(_github),
                ),
              ),
              SizedBox(width: context.r(8)),
              Expanded(
                child: _DevActionBtn(
                  image: Image.asset(
                    AppImages.linkedIn,
                    width: context.r(18),
                    height: context.r(18),
                  ),
                  label: 'LinkedIn',
                  color: const Color(0xFF0A66C2),
                  onTap: () => _launch(_linkedin),
                ),
              ),
              SizedBox(width: context.r(8)),
              Expanded(
                child: _DevActionBtn(
                  image: Image.asset(
                    AppImages.email,
                    width: context.r(18),
                    height: context.r(18),
                  ),
                  label: 'Email',
                  color: const Color(0xFF039BE5),
                  onTap: () => _launch('mailto:$_email'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skill chip ────────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(6)),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: context.sp(10),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Developer action button ───────────────────────────────────────────────────

class _DevActionBtn extends StatefulWidget {
  final Widget image;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const _DevActionBtn({
    required this.image,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DevActionBtn> createState() => _DevActionBtnState();
}

class _DevActionBtnState extends State<_DevActionBtn> {
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
        padding: context.rSymmetric(vertical: 10),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: widget.color.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            _loading
                ? SizedBox(
                    width: context.r(16),
                    height: context.r(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.color,
                    ),
                  )
                : widget.image,
            SizedBox(height: context.r(4)),
            Text(
              widget.label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
