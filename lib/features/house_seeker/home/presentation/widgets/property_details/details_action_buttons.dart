import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Main action buttons bar (seeker view) ────────────────────────────────────

class DetailsActionButtons extends StatefulWidget {
  final Future<void> Function() onWhatsApp;
  final Future<void> Function() onLocation;
  final Future<void> Function()? onChat;

  const DetailsActionButtons({
    super.key,
    required this.onWhatsApp,
    required this.onLocation,
    this.onChat,
  });

  @override
  State<DetailsActionButtons> createState() => _DetailsActionButtonsState();
}

class _DetailsActionButtonsState extends State<DetailsActionButtons> {
  bool _loadingWhatsApp = false;
  bool _loadingLocation = false;
  bool _loadingChat = false;

  bool get _anyLoading => _loadingWhatsApp || _loadingLocation || _loadingChat;

  Future<void> _handle(
    Future<void> Function() action,
    void Function(bool) setLoading,
  ) async {
    if (_anyLoading) return;
    setLoading(true);
    try {
      await action();
    } finally {
      if (mounted) setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 16,
        right: 16,
        top: 14,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: context.r(18),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ActionButton(
              label: 'details_btn_whatsapp'.tr(context),
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              isLoading: _loadingWhatsApp,
              filled: true,
              onTap: () => _handle(
                widget.onWhatsApp,
                (v) => setState(() => _loadingWhatsApp = v),
              ),
            ),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'details_btn_location'.tr(context),
              icon: Icons.location_on_rounded,
              color: const Color(0xFF1E88E5),
              isLoading: _loadingLocation,
              filled: false,
              onTap: () => _handle(
                widget.onLocation,
                (v) => setState(() => _loadingLocation = v),
              ),
            ),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'details_btn_chat'.tr(context),
              icon: Icons.forum_outlined,
              color: AppColors.primary,
              isLoading: _loadingChat,
              filled: false,
              onTap: () => _handle(
                widget.onChat ?? () async {},
                (v) => setState(() => _loadingChat = v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared animated button ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: context.r(50),
        padding: context.rSymmetric(horizontal: filled ? 12 : 10),
        decoration: BoxDecoration(
          color: filled
              ? (isLoading ? color.withValues(alpha: 0.65) : color)
              : color.withValues(alpha: isLoading ? 0.03 : 0.06),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: filled
              ? null
              : Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loader'),
                      width: context.r(18),
                      height: context.r(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: filled ? Colors.white : color,
                      ),
                    )
                  : Icon(
                      key: const ValueKey('icon'),
                      icon,
                      color: filled ? Colors.white : color,
                      size: context.r(filled ? 18 : 17),
                    ),
            ),
            if (!isLoading) ...[
              SizedBox(width: context.r(5)),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(filled ? 12 : 11),
                    fontWeight: FontWeight.w800,
                    color: filled ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
