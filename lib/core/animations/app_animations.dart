// lib/core/animations/app_animations.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Enterprise Animation System — No external packages.
/// Usage: AppAnimations.fade(child: widget, duration: 600.ms)
abstract final class AppAnimations {
  // ── Private Helpers ────────────────────────────────────────────────────────

  /// Adds delay by stretching total duration and pushing animation start
  /// via an Interval. The real duration starts at [delay / total].
  static Curve _delayCurve(Duration delay, Duration duration, Curve curve) {
    if (delay == Duration.zero) return curve;
    final total = delay.inMilliseconds + duration.inMilliseconds;
    return Interval(delay.inMilliseconds / total, 1.0, curve: curve);
  }

  static Duration _totalDuration(Duration delay, Duration duration) {
    return delay == Duration.zero
        ? duration
        : Duration(
            milliseconds: delay.inMilliseconds + duration.inMilliseconds,
          );
  }

  // ── 1. Fade ────────────────────────────────────────────────────────────────

  /// AppAnimations.fade(child: myWidget, duration: Duration(milliseconds: 600))
  static Widget fade({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    double beginOpacity = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginOpacity, end: 1.0),
      duration: _totalDuration(delay, duration),
      curve: _delayCurve(delay, duration, curve),
      child: child,
      builder: (_, value, child) => Opacity(
        // ✅ KEY FIX: clamp prevents assertion error from overshooting curves
        opacity: value.clamp(0.0, 1.0),
        child: child,
      ),
    );
  }

  // ── 2. Scale ───────────────────────────────────────────────────────────────

  /// AppAnimations.scale(child: myWidget, duration: Duration(milliseconds: 800))
  static Widget scale({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.elasticOut,
    Duration delay = Duration.zero,
    double beginScale = 0.0,
    Alignment alignment = Alignment.center,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: 1.0),
      duration: _totalDuration(delay, duration),
      curve: _delayCurve(delay, duration, curve),
      child: child,
      builder: (_, value, child) => Transform.scale(
        // ✅ clamp: elasticOut overshoots — safe for Transform (no assertion),
        //    but clamped to keep visuals clean
        scale: value.clamp(0.0, 1.2),
        alignment: alignment,
        child: child,
      ),
    );
  }

  // ── 3. Slide ───────────────────────────────────────────────────────────────

  /// AppAnimations.slide(child: myWidget, duration: Duration(milliseconds: 500))
  static Widget slide({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
    SlideDirection direction = SlideDirection.up,
    double distance = 40.0,
  }) {
    final begin = _slideOffset(direction, distance);
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: _totalDuration(delay, duration),
      curve: _delayCurve(delay, duration, curve),
      child: child,
      builder: (_, value, child) =>
          Transform.translate(offset: value, child: child),
    );
  }

  static Offset _slideOffset(SlideDirection direction, double distance) {
    return switch (direction) {
      SlideDirection.up => Offset(0, distance),
      SlideDirection.down => Offset(0, -distance),
      SlideDirection.left => Offset(-distance, 0),
      SlideDirection.right => Offset(distance, 0),
    };
  }

  // ── 4. Rotation ────────────────────────────────────────────────────────────

  /// AppAnimations.rotation(child: myWidget, duration: Duration(milliseconds: 700))
  static Widget rotation({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    double beginDegrees = -180.0,
    double endDegrees = 0.0,
    Alignment alignment = Alignment.center,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginDegrees, end: endDegrees),
      duration: _totalDuration(delay, duration),
      curve: _delayCurve(delay, duration, curve),
      child: child,
      builder: (_, value, child) => Transform.rotate(
        angle: value * math.pi / 180,
        alignment: alignment,
        child: child,
      ),
    );
  }

  // ── 5. Size (reveal) ───────────────────────────────────────────────────────

  /// AppAnimations.size(child: myWidget, duration: Duration(milliseconds: 500))
  /// ✅ FIX: value is clamped before being used as heightFactor/widthFactor
  /// to prevent the 99327px overflow caused by elasticOut overshoot.
  static Widget size({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    Axis axis = Axis.vertical,
    double beginSize = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginSize, end: 1.0),
      duration: _totalDuration(delay, duration),
      curve: _delayCurve(delay, duration, curve),
      child: child,
      builder: (_, value, child) => ClipRect(
        child: Align(
          alignment: Alignment.center,
          // ✅ KEY FIX: clamp to [0,1] — layout factors cannot be > 1
          heightFactor: axis == Axis.vertical ? value.clamp(0.0, 1.0) : 1.0,
          widthFactor: axis == Axis.horizontal ? value.clamp(0.0, 1.0) : 1.0,
          child: child,
        ),
      ),
    );
  }

  // ── 6. Combined ────────────────────────────────────────────────────────────

  /// Composes two animations together.
  /// AppAnimations.combined(type: CombineType.fadeSlide, child: ..., duration: ...)
  static Widget combined({
    required Widget child,
    required Duration duration,
    CombineType type = CombineType.fadeSlide,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    SlideDirection direction = SlideDirection.up,
    double slideDistance = 40.0,
    double beginScale = 0.0,
  }) {
    return switch (type) {
      CombineType.fadeSlide => fade(
        duration: duration,
        delay: delay,
        curve: curve,
        child: slide(
          duration: duration,
          delay: delay,
          curve: curve,
          direction: direction,
          distance: slideDistance,
          child: child,
        ),
      ),
      CombineType.fadeScale => fade(
        duration: duration,
        delay: delay,
        curve: curve,
        child: scale(
          duration: duration,
          delay: delay,
          curve: curve,
          beginScale: beginScale,
          child: child,
        ),
      ),
      CombineType.scaleSlide => scale(
        duration: duration,
        delay: delay,
        curve: curve,
        beginScale: beginScale,
        child: slide(
          duration: duration,
          delay: delay,
          curve: curve,
          direction: direction,
          distance: slideDistance,
          child: child,
        ),
      ),
    };
  }
}

// ── Supporting Enums ──────────────────────────────────────────────────────────

enum SlideDirection { up, down, left, right }

enum CombineType { fadeSlide, fadeScale, scaleSlide }
