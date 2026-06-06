import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An animated quick-contact button (Phone / WhatsApp / Email).
/// Shows a spinner while the URL is launching.
class HelpQuickContactBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const HelpQuickContactBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<HelpQuickContactBtn> createState() => _HelpQuickContactBtnState();
}

class _HelpQuickContactBtnState extends State<HelpQuickContactBtn> {
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
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _loading ? 0.05 : 0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(44),
              height: context.r(44),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(context.r(11)),
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
