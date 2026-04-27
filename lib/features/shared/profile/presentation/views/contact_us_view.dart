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
          // ── Gradient header ──────────────────────────────────────────
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
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: context.r(28),
                        ),
                      ),
                      SizedBox(height: context.r(10)),
                      Text(
                        'contact_title'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'contact_subtitle'.tr(context),
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

                // ── Direct contact channels ──────────────────────────────
                _SectionLabel(label: 'contact_channels_title'.tr(context)),
                SizedBox(height: context.r(12)),

                // Phone card — tap = call, long-press = copy
                _ContactCard(
                  icon: Icons.phone_rounded,
                  gradient: const [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  title: 'contact_phone_title'.tr(context),
                  value: _phone,
                  badge: 'contact_badge_instant'.tr(context),
                  badgeColor: const Color(0xFF43A047),
                  onTap: () => _launch('tel:+20$_phone'),
                  onLongPress: () => _copyToClipboard(
                    context,
                    _phone,
                    'contact_phone_title'.tr(context),
                  ),
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

                // Email card
                _ContactCard(
                  icon: Icons.email_rounded,
                  gradient: const [Color(0xFF0277BD), Color(0xFF039BE5)],
                  title: 'contact_email_title'.tr(context),
                  value: _email,
                  badge: 'contact_badge_24h'.tr(context),
                  badgeColor: const Color(0xFF039BE5),
                  onTap: () => _launch('mailto:$_email'),
                  onLongPress: () => _copyToClipboard(
                    context,
                    _email,
                    'contact_email_title'.tr(context),
                  ),
                ),
                SizedBox(height: context.r(10)),

                // Instagram card
                _ContactCard(
                  icon: Icons.photo_camera_rounded,
                  gradient: const [Color(0xFFE91E63), Color(0xFFAD1457)],
                  title: 'Instagram',
                  value: '@$_instagram',
                  badge: 'contact_badge_dm'.tr(context),
                  badgeColor: const Color(0xFFE91E63),
                  onTap: () => _launch('https://instagram.com/$_instagram'),
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

                SizedBox(height: context.r(24)),

                // ── Working hours info card ───────────────────────────────
                _SectionLabel(label: 'contact_hours_title'.tr(context)),
                SizedBox(height: context.r(12)),
                Container(
                  padding: context.rAll(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.r(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(44),
                        height: context.r(44),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(context.r(12)),
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: AppColors.primary,
                          size: context.r(22),
                        ),
                      ),
                      SizedBox(width: context.r(14)),
                      Expanded(
                        child: Text(
                          'contact_hours_value'.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(13),
                            color: Colors.grey.shade700,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
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

// ── Contact card with loading indicator ──────────────────────────────────────

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final Future<void> Function() onTap;
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
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
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
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(context.r(12)),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(widget.icon, color: Colors.white, size: context.r(22)),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11),
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    widget.value,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(13.5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  SizedBox(height: context.r(4)),
                  Container(
                    padding: context.rSymmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.badgeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(context.r(6)),
                    ),
                    child: Text(
                      widget.badge,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: widget.badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Mini action button ────────────────────────────────────────────────────────

class _MiniAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final Future<void> Function() onTap;

  const _MiniAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_MiniAction> createState() => _MiniActionState();
}

class _MiniActionState extends State<_MiniAction> {
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
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: _loading ? null : _handle,
        child: Container(
          width: context.r(36),
          height: context.r(36),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: _loading
              ? Padding(
                  padding: EdgeInsets.all(context.r(9)),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.color,
                  ),
                )
              : Icon(widget.icon, color: widget.color, size: context.r(18)),
        ),
      ),
    );
  }
}

// ── Social button with loading ────────────────────────────────────────────────

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
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
      await widget.onTap();
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
        padding: context.rSymmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _loading ? 0.05 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
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
                : Icon(widget.icon, color: widget.color, size: context.r(24)),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.r(4),
          height: context.r(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.r(8)),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: context.sp(13.5),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
      ],
    );
  }
}
