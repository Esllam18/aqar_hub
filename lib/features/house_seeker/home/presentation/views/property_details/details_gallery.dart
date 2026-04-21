// lib/features/house_seeker/home/presentation/views/property_details/details_gallery.dart
//
// Auto-sliding image gallery (SliverAppBar) + fullscreen viewer.

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';

// ── Sliver gallery ────────────────────────────────────────────────────────────

class DetailsGallerySliver extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback onBack;
  const DetailsGallerySliver({
    super.key,
    required this.imageUrls,
    required this.onBack,
  });

  @override
  State<DetailsGallerySliver> createState() => _DetailsGallerySliverState();
}

class _DetailsGallerySliverState extends State<DetailsGallerySliver> {
  late final PageController _ctrl;
  Timer? _timer;
  int _current = 0;

  List<String> get _images =>
      widget.imageUrls.where((u) => u.trim().isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients) return;
      _ctrl.animateToPage(
        (_current + 1) % _images.length,
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

  void _openFullscreen(int index) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          DetailsFullscreenGallery(images: _images, initialIndex: index),
    ),
  );

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
            if (images.isNotEmpty)
              GestureDetector(
                onTap: () => _openFullscreen(_current),
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: images.length,
                  onPageChanged: (i) {
                    setState(() => _current = i);
                    _startTimer();
                  },
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade300),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  ),
                ),
              )
            else
              Container(color: Colors.grey.shade300),
            // Gradient overlay
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
            // Back button
            Positioned(
              top: MediaQuery.paddingOf(context).top + context.r(12),
              right: context.r(16),
              child: _CircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: widget.onBack,
              ),
            ),
            // Fullscreen button
            if (images.isNotEmpty)
              Positioned(
                top: MediaQuery.paddingOf(context).top + context.r(12),
                left: context.r(16),
                child: _CircleBtn(
                  icon: Icons.fullscreen_rounded,
                  onTap: () => _openFullscreen(_current),
                ),
              ),
            // Counter badge
            if (images.length > 1)
              Positioned(
                top: MediaQuery.paddingOf(context).top + context.r(12),
                left: context.r(62),
                child: Container(
                  padding: context.rSymmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(context.r(20)),
                  ),
                  child: Text(
                    '${_current + 1} / ${images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            // Dot indicators
            if (images.length > 1)
              Positioned(
                bottom: context.r(18),
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    return AnimatedContainer(
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
                    );
                  }),
                ),
              ),
            // Thumbnail strip
            if (images.length > 1)
              Positioned(
                bottom: context.r(30),
                left: 0,
                right: 0,
                child: SizedBox(
                  height: context.r(46),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: context.rSymmetric(horizontal: 12),
                    itemCount: images.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _ctrl.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: context.rOnly(right: 6),
                        width: context.r(_current == i ? 52 : 40),
                        height: context.r(_current == i ? 46 : 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.r(8)),
                          border: Border.all(
                            color: _current == i
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: images[i],
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade400),
                        ),
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

// ── Circle button ─────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(38),
        height: context.r(38),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: context.r(18)),
      ),
    );
  }
}

// ── Fullscreen viewer ─────────────────────────────────────────────────────────

class DetailsFullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const DetailsFullscreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<DetailsFullscreenGallery> createState() =>
      _DetailsFullscreenGalleryState();
}

class _DetailsFullscreenGalleryState extends State<DetailsFullscreenGallery> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.images[i],
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                '${_current + 1} / ${widget.images.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
