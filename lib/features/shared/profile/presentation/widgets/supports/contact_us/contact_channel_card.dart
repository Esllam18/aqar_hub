import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A tappable contact channel card (Phone / Email / Instagram).
/// Tap = launch URL, long-press = copy to clipboard.
/// Shows a spinner while the URL is being opened.
class ContactChannelCard extends StatefulWidget {
  final ImageProvider image;
  final List<Color> gradient;
  final String titleKey;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Future<void> Function() onTap;
  final Widget? trailingActions;

  const ContactChannelCard({
    super.key,
    required this.image,
    required this.gradient,
    required this.titleKey,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
    this.trailingActions,
  });

  @override
  State<ContactChannelCard> createState() => _ContactChannelCardState();
}

class _ContactChannelCardState extends State<ContactChannelCard> {
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

  void _copyValue() {
    Clipboard.setData(ClipboardData(text: widget.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.titleKey.tr(context)} ${'contact_copied'.tr(context)}',
          style: GoogleFonts.tajawal(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _handle,
      onLongPress: _copyValue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(18)),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(
                alpha: _loading ? 0.04 : 0.10,
              ),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: context.r(50),
              height: context.r(50),
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
                      padding: EdgeInsets.all(context.r(13)),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Image(
                      image: widget
                          .image, // already an ImageProvider, no .image needed
                      width: context.r(18),
                      height: context.r(18),
                    ),
            ),
            SizedBox(width: context.r(14)),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.titleKey.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(11),
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(width: context.r(6)),
                      Container(
                        padding: context.rSymmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.badgeColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(context.r(6)),
                        ),
                        child: Text(
                          widget.badgeText,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w700,
                            color: widget.badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.r(2)),
                  Text(
                    widget.value,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  SizedBox(height: context.r(3)),
                  Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: context.r(11),
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: context.r(3)),
                      Text(
                        'contact_long_press_copy'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(10),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing actions or arrow
            if (widget.trailingActions != null)
              widget.trailingActions!
            else
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

// ── Small circular action button (e.g. WhatsApp / Telegram next to phone) ────

class ContactMiniActionBtn extends StatefulWidget {
  final ImageProvider image;
  final Color color;
  final String tooltip;
  final Future<void> Function() onTap;

  const ContactMiniActionBtn({
    super.key,
    required this.image,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<ContactMiniActionBtn> createState() => _ContactMiniActionBtnState();
}

class _ContactMiniActionBtnState extends State<ContactMiniActionBtn> {
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
          width: context.r(38),
          height: context.r(38),
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
              : Image(
                  image: widget
                      .image, // already an ImageProvider, no .image needed
                  width: context.r(18),
                  height: context.r(18),
                ),
        ),
      ),
    );
  }
}
