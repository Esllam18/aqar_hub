// lib/features/shared/chat/presentation/views/chat/chat_video_bubble.dart
//
// In-chat video player bubble + fullscreen video screen.

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class VideoBubble extends StatefulWidget {
  final String? url;
  final bool isMine, isPending;
  const VideoBubble({
    super.key,
    required this.isMine,
    this.url,
    this.isPending = false,
  });

  @override
  State<VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble> {
  VideoPlayerController? _ctrl;
  bool _initialized = false, _error = false, _playing = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.isPending || widget.url == null || widget.url!.isEmpty) return;
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      ctrl.addListener(_onUpdate);
      setState(() {
        _ctrl = ctrl;
        _initialized = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _onUpdate() {
    if (!mounted) return;
    final p = _ctrl?.value.isPlaying ?? false;
    if (p != _playing) setState(() => _playing = p);
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onUpdate);
    _ctrl?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_ctrl == null) return;
    _playing ? _ctrl!.pause() : _ctrl!.play();
  }

  void _openFullscreen(BuildContext ctx) {
    if (_ctrl == null || !_initialized || widget.url == null) return;
    final was = _playing;
    _ctrl!.pause();
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenVideo(url: widget.url!, startPos: _ctrl!.value.position),
        fullscreenDialog: true,
      ),
    ).then((_) {
      if (mounted && was) _ctrl!.play();
    });
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (widget.isPending) return _PendingVideo();

    return Container(
      width: context.r(220),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(context.r(14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _error
          ? SizedBox(
              height: context.r(110),
              child: Center(
                child: Icon(
                  Icons.video_file_outlined,
                  color: Colors.white38,
                  size: context.r(36),
                ),
              ),
            )
          : !_initialized
          ? SizedBox(
              height: context.r(110),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: _ctrl!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_ctrl!),
                      GestureDetector(
                        onTap: _toggle,
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: _playing
                              ? null
                              : Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: context.r(44),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: context.r(6),
                        right: context.r(6),
                        child: GestureDetector(
                          onTap: () => _openFullscreen(context),
                          child: Container(
                            padding: context.rAll(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(context.r(6)),
                            ),
                            child: Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: context.r(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _ctrl!,
                  builder: (_, v, __) {
                    final pos = v.position;
                    final dur = v.duration;
                    return Container(
                      color: Colors.black87,
                      padding: context.rSymmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggle,
                            child: Icon(
                              _playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: context.r(22),
                            ),
                          ),
                          SizedBox(width: context.r(6)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 10,
                                ),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: pos.inMilliseconds.toDouble().clamp(
                                  0,
                                  dur.inMilliseconds.toDouble(),
                                ),
                                max: dur.inMilliseconds.toDouble(),
                                onChanged: (val) => _ctrl!.seekTo(
                                  Duration(milliseconds: val.toInt()),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${_fmt(pos)}/${_fmt(dur)}',
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(9),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

// ── Pending upload placeholder ────────────────────────────────────────────────

class _PendingVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: context.r(220),
    height: context.r(120),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(context.r(14)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        SizedBox(height: context.r(8)),
        Text(
          'chat_uploading'.tr(context),
          style: GoogleFonts.tajawal(
            fontSize: context.r(11),
            color: Colors.white54,
          ),
        ),
      ],
    ),
  );
}

// ── Fullscreen video ──────────────────────────────────────────────────────────

class _FullscreenVideo extends StatefulWidget {
  final String url;
  final Duration startPos;
  const _FullscreenVideo({required this.url, required this.startPos});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _ctrl.seekTo(widget.startPos);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Center(
      child: _ctrl.value.isInitialized
          ? AspectRatio(
              aspectRatio: _ctrl.value.aspectRatio,
              child: VideoPlayer(_ctrl),
            )
          : const CircularProgressIndicator(color: Colors.white),
    ),
  );
}
