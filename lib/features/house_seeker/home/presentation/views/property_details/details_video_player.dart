// lib/features/house_seeker/home/presentation/views/property_details/details_video_player.dart
//
// In-app video player card for the property details screen.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class DetailsVideoPlayer extends StatefulWidget {
  final String url;
  const DetailsVideoPlayer({super.key, required this.url});

  @override
  State<DetailsVideoPlayer> createState() => _DetailsVideoPlayerState();
}

class _DetailsVideoPlayerState extends State<DetailsVideoPlayer> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      }).catchError((_) {
        if (mounted) setState(() => _error = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: context.r(14),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: context.rOnly(left: 16, right: 16, top: 14, bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: context.rAll(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(Icons.play_circle_rounded,
                      color: AppColors.primary, size: context.r(18)),
                ),
                SizedBox(width: context.r(10)),
                Text(
                  'details_btn_video'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
              ],
            ),
          ),
          // Video area
          AspectRatio(
            aspectRatio: _initialized ? _ctrl.value.aspectRatio : 16 / 9,
            child: _error
                ? Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(Icons.video_file_outlined,
                          color: Colors.grey.shade400, size: context.r(48)),
                    ),
                  )
                : !_initialized
                    ? Container(
                        color: Colors.grey.shade200,
                        child:
                            const Center(child: CircularProgressIndicator()),
                      )
                    : VideoPlayer(_ctrl),
          ),
          // Controls
          if (_initialized)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _ctrl,
              builder: (_, v, __) {
                final pos = v.position;
                final dur = v.duration;
                return Padding(
                  padding:
                      context.rSymmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: AppColors.primary,
                        ),
                        child: Slider(
                          value: pos.inMilliseconds
                              .toDouble()
                              .clamp(0, dur.inMilliseconds.toDouble()),
                          max: dur.inMilliseconds.toDouble(),
                          onChanged: (val) => _ctrl.seekTo(
                              Duration(milliseconds: val.toInt())),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.r(4)),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                v.isPlaying
                                    ? Icons.pause_circle_rounded
                                    : Icons.play_circle_rounded,
                                color: AppColors.primary,
                                size: context.r(32),
                              ),
                              onPressed: () => v.isPlaying
                                  ? _ctrl.pause()
                                  : _ctrl.play(),
                            ),
                            Text(
                              '${_fmt(pos)} / ${_fmt(dur)}',
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(11),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
