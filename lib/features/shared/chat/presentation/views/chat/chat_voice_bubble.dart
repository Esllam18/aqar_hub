// lib/features/shared/chat/presentation/views/chat/chat_voice_bubble.dart
//
// Audio voice message bubble with waveform visualiser and AudioPlayer.

import 'dart:async';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceBubble extends StatefulWidget {
  final int durationSecs;
  final bool isMine;
  final String? mediaUrl;

  const VoiceBubble({
    super.key,
    required this.durationSecs,
    required this.isMine,
    this.mediaUrl,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  final _player = AudioPlayer();
  bool _playing = false;
  double _progress = 0.0;
  StreamSubscription? _posSub, _stateSub;

  static const _waveHeights = [
    0.3, 0.6, 0.9, 0.5, 0.8, 0.4, 1.0, 0.7, 0.5, 0.9,
    0.6, 0.4, 0.8, 1.0, 0.5, 0.7, 0.9, 0.4, 0.6, 1.0,
    0.8, 0.5, 0.3, 0.7, 0.9, 0.4, 0.6, 0.5,
  ];

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _posSub = _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      final t = widget.durationSecs > 0 ? widget.durationSecs : 1;
      setState(() => _progress = (pos.inSeconds / t).clamp(0.0, 1.0));
    });
    _stateSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _playing = false; _progress = 0; });
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.mediaUrl == null || widget.mediaUrl!.isEmpty) return;
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
    } else {
      await _player.play(UrlSource(widget.mediaUrl!));
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mins = widget.durationSecs ~/ 60;
    final secs = (widget.durationSecs % 60).toString().padLeft(2, '0');
    final bg = widget.isMine ? const Color(0xFFDCF8C6) : Colors.white;
    final accent =
        widget.isMine ? const Color(0xFF25D366) : AppColors.primary;

    return Container(
      constraints: BoxConstraints(
          maxWidth: context.r(240), minWidth: context.r(180)),
      padding:
          context.rOnly(left: 10, right: 10, top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(18)),
          topRight: Radius.circular(context.r(18)),
          bottomLeft: Radius.circular(
              widget.isMine ? context.r(18) : context.r(4)),
          bottomRight: Radius.circular(
              widget.isMine ? context.r(4) : context.r(18)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: context.r(38),
              height: context.r(38),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: context.r(22),
              ),
            ),
          ),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: context.r(28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(_waveHeights.length, (i) {
                      final h = _waveHeights[i % _waveHeights.length];
                      final played = (i / _waveHeights.length) <= _progress;
                      return Container(
                        width: context.r(2.5),
                        height: context.r(28) * h,
                        decoration: BoxDecoration(
                          color: played
                              ? accent
                              : accent.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(context.r(2)),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: context.r(3)),
                Text(
                  '$mins:$secs',
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: widget.isMine
                        ? Colors.green.shade800.withValues(alpha: 0.7)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
