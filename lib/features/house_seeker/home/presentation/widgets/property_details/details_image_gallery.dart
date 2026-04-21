import 'dart:async';

import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DetailsImageGallery — SliverAppBar with auto-sliding PageView.
// Tap any image to open a full-screen immersive viewer with pinch-to-zoom.
// ─────────────────────────────────────────────────────────────────────────────

class DetailsImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final VoidCallback onBack;

  const DetailsImageGallery({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.onBack,
  });

  @override
  State<DetailsImageGallery> createState() => _DetailsImageGalleryState();
}

class _DetailsImageGalleryState extends State<DetailsImageGallery> {
  late final PageController _ctrl;
  Timer? _timer;
  int _current = 0;

  List<String> get _images =>
      widget.imageUrls.where((e) => e.trim().isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    if (_images.length < 2) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients) return;
      final next = (_current + 1) % _images.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _openFullScreen(int index) {
    _timer?.cancel();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) =>
            _FullScreenGallery(images: _images, initialIndex: index),
      ),
    ).then((_) => _startAutoSlide());
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return SliverAppBar(
      expandedHeight: context.r(320),
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Images ──────────────────────────────────────────────────────
            if (images.isNotEmpty)
              GestureDetector(
                onTap: () => _openFullScreen(_current),
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: images.length,
                  onPageChanged: (i) {
                    setState(() => _current = i);
                    _startAutoSlide();
                  },
                  itemBuilder: (_, i) => Hero(
                    tag: 'property_image_$i',
                    child: CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade300),
                      errorWidget: (_, __, ___) =>
                          Container(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              )
            else
              Container(color: Colors.grey.shade300),

            // ── Gradient overlay ─────────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ),

            // ── Back button (RTL-aware: right side) ──────────────────────────
            Positioned(
              top: MediaQuery.paddingOf(context).top + context.r(12),
              right: context.r(16),
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: widget.onBack,
              ),
            ),

            // ── Counter + expand hint ────────────────────────────────────────
            if (images.length > 1)
              Positioned(
                top: MediaQuery.paddingOf(context).top + context.r(12),
                left: context.r(16),
                child: GestureDetector(
                  onTap: () => _openFullScreen(_current),
                  child: Container(
                    padding: context.rSymmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.circular(context.r(20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white70,
                          size: context.r(12),
                        ),
                        SizedBox(width: context.r(5)),
                        Text(
                          '${_current + 1} / ${images.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Dot indicators ───────────────────────────────────────────────
            if (images.length > 1)
              Positioned(
                bottom: context.r(18),
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length > 10 ? 10 : images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: context.rSymmetric(horizontal: 3),
                      width: _current == i ? context.r(18) : context.r(6),
                      height: context.r(6),
                      decoration: BoxDecoration(
                        color: _current == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(context.r(6)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen immersive gallery
// Swipe left/right, pinch-to-zoom, tap to toggle chrome.
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _ctrl;
  late int _current;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() => setState(() => _showUI = !_showUI);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Zoomable paged images ──────────────────────────────────────────
          GestureDetector(
            onTap: _toggleUI,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Hero(
                  tag: 'property_image_$i',
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white30,
                        strokeWidth: 1.5,
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white30,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top chrome ────────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.35],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.r(12),
                      vertical: context.r(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        if (widget.images.length > 1)
                          Container(
                            padding: context.rSymmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(
                                context.r(20),
                              ),
                            ),
                            child: Text(
                              '${_current + 1} / ${widget.images.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        SizedBox(width: context.r(40)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom dot indicators ──────────────────────────────────────────
          if (widget.images.length > 1)
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.4],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: context.r(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.images.length > 12 ? 12 : widget.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _current == i ? 20.0 : 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: _current == i
                                  ? Colors.white
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared circle icon button (used in both normal and full-screen gallery)
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(40),
        height: context.r(40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.32),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: context.r(18)),
      ),
    );
  }
}
