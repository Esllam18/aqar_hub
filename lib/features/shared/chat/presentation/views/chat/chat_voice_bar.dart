// lib/.../chat/chat_voice_bar.dart — Recording bar shown while mic is held
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatVoiceBar extends StatefulWidget {
  final int secs;
  final double dragOffset;
  final void Function(double dx) onDragUpdate;
  final VoidCallback onRelease;
  final VoidCallback onCancel;

  const ChatVoiceBar({
    super.key,
    required this.secs,
    required this.dragOffset,
    required this.onDragUpdate,
    required this.onRelease,
    required this.onCancel,
  });

  @override State<ChatVoiceBar> createState() => _State();
}

class _State extends State<ChatVoiceBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override void initState() { super.initState(); _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true); }
  @override void dispose() { _pulse.dispose(); super.dispose(); }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cancelling = widget.dragOffset < -60;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: context.r(8), right: context.r(8), top: context.r(8),
          bottom: context.r(8) + MediaQuery.paddingOf(context).bottom),
      child: Row(children: [
        GestureDetector(onTap: widget.onCancel,
          child: Container(width: context.r(44), height: context.r(44),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: context.r(22)))),
        SizedBox(width: context.r(8)),
        Expanded(child: GestureDetector(
          onHorizontalDragUpdate: (d) => widget.onDragUpdate(d.localPosition.dx - 200),
          onHorizontalDragEnd: (_) => cancelling ? widget.onCancel() : widget.onRelease(),
          child: Container(height: context.r(44),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(context.r(22))),
            padding: context.rSymmetric(horizontal: 14),
            child: Row(children: [
              AnimatedBuilder(animation: _pulse, builder: (_, __) => Container(
                width: context.r(9), height: context.r(9),
                decoration: BoxDecoration(color: Color.lerp(Colors.redAccent, Colors.red.shade800, _pulse.value), shape: BoxShape.circle))),
              SizedBox(width: context.r(8)),
              Text(_fmt(widget.secs), style: GoogleFonts.tajawal(fontSize: context.sp(14), fontWeight: FontWeight.w600, color: const Color(0xFF1B2D5E))),
              Expanded(child: AnimatedOpacity(opacity: cancelling ? 1.0 : 0.6, duration: const Duration(milliseconds: 200),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.chevron_left_rounded, color: cancelling ? Colors.redAccent : Colors.grey.shade400, size: context.r(16)),
                  Text(cancelling ? 'chat_voice_release_cancel'.tr(context) : 'chat_voice_slide_cancel'.tr(context),
                    style: GoogleFonts.tajawal(fontSize: context.sp(11), color: cancelling ? Colors.redAccent : Colors.grey.shade400)),
                ]))),
            ])))),
        SizedBox(width: context.r(8)),
        GestureDetector(onTap: widget.onRelease,
          child: Container(width: context.r(44), height: context.r(44),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(Icons.send_rounded, color: Colors.white, size: context.r(20)))),
      ]));
  }
}
