import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  static const _phone = '01155374945';
  static const _email = 'esllam.maherr@gmail.com';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: context.r(28),
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

                // ── Quick contact buttons ──────────────────────────────
                _SectionLabel(label: 'help_section_contact'.tr(context)),
                SizedBox(height: context.r(10)),
                Row(
                  children: [
                    Expanded(
                      child: _QuickContactBtn(
                        icon: Icons.phone_rounded,
                        label: 'contact_phone_title'.tr(context),
                        color: AppColors.primary,
                        onTap: () => _launch('tel:+20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: _QuickContactBtn(
                        icon: Icons.chat_rounded,
                        label: 'contact_chat_title'.tr(context),
                        color: const Color(0xFF43A047),
                        onTap: () => _launch('https://wa.me/20$_phone'),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: _QuickContactBtn(
                        icon: Icons.email_rounded,
                        label: 'contact_email_title'.tr(context),
                        color: const Color(0xFF039BE5),
                        onTap: () => _launch('mailto:$_email'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.r(24)),

                // ── FAQ ────────────────────────────────────────────────
                _SectionLabel(label: 'help_section_faq'.tr(context)),
                SizedBox(height: context.r(10)),
                const _FaqTile(questionKey: 'help_q1', answerKey: 'help_a1'),
                const _FaqTile(questionKey: 'help_q2', answerKey: 'help_a2'),
                const _FaqTile(questionKey: 'help_q3', answerKey: 'help_a3'),
                const _FaqTile(questionKey: 'help_q4', answerKey: 'help_a4'),

                SizedBox(height: context.r(24)),

                // ── Report a problem ───────────────────────────────────
                _SectionLabel(label: 'help_section_report'.tr(context)),
                SizedBox(height: context.r(10)),
                _ReportCard(
                  onTap: () => _launch(
                    'mailto:$_email?subject=AqarHub%20%E2%80%94%20Report%20%2F%20Bug&body=Describe%20your%20issue%20here...',
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(
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
          fontSize: context.sp(14),
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}

// ── Quick contact button with loading ────────────────────────────────────────

class _QuickContactBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const _QuickContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickContactBtn> createState() => _QuickContactBtnState();
}

class _QuickContactBtnState extends State<_QuickContactBtn> {
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
        padding: context.rSymmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _loading ? 0.06 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: context.r(42),
              height: context.r(42),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(context.r(10)),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.color,
                      ),
                    )
                  : Icon(widget.icon, color: widget.color, size: context.r(20)),
            ),
            SizedBox(height: context.r(6)),
            Text(
              widget.label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ tile ─────────────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final String questionKey;
  final String answerKey;
  const _FaqTile({required this.questionKey, required this.answerKey});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _rotate = Tween(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: context.rOnly(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: _open
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: _open
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: context.rAll(14),
              child: Row(
                children: [
                  Container(
                    width: context.r(32),
                    height: context.r(32),
                    decoration: BoxDecoration(
                      color: _open
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(context.r(9)),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: context.r(16),
                      color: _open ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(width: context.r(12)),
                  Expanded(
                    child: Text(
                      widget.questionKey.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: _open ? AppColors.primary : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _open ? AppColors.primary : Colors.grey.shade400,
                      size: context.r(22),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: context.rOnly(left: 58, right: 14, bottom: 14),
                child: Text(
                  widget.answerKey.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    color: Colors.grey.shade600,
                    height: 1.7,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Report card with loading ──────────────────────────────────────────────────

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
                  ? Icons.arrow_back_ios_new_rounded
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
