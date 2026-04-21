import 'package:flutter/material.dart';
import 'transition_type.dart';

class NavigationService {
  NavigationService._();

  static final NavigationService instance = NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => navigatorKey.currentState!;

  // ── Route Builder ─────────────────────────────────────────────────────────

  Route<T> _buildRoute<T>(Widget page, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        );

      case TransitionType.scale:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );

      case TransitionType.slideFromBottom:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(0.0, 1.0);
            final tween = Tween(
              begin: begin,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case TransitionType.none:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

      case TransitionType.slide:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            final tween = Tween(
              begin: begin,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
    }
  }

  // ── Core Methods ──────────────────────────────────────────────────────────

  Future<T?> push<T>(
    Widget page, {
    TransitionType transition = TransitionType.slide,
  }) => _navigator.push<T>(_buildRoute<T>(page, transition));

  Future<T?> replace<T, R>(
    Widget page, {
    TransitionType transition = TransitionType.slide,
    R? result,
  }) => _navigator.pushReplacement<T, R>(
    _buildRoute<T>(page, transition),
    result: result,
  );

  Future<T?> offAll<T>(
    Widget page, {
    TransitionType transition = TransitionType.fade,
  }) => _navigator.pushAndRemoveUntil<T>(
    _buildRoute<T>(page, transition),
    (_) => false,
  );

  Future<T?> offUntil<T>(
    Widget page,
    RoutePredicate predicate, {
    TransitionType transition = TransitionType.slide,
  }) => _navigator.pushAndRemoveUntil<T>(
    _buildRoute<T>(page, transition),
    predicate,
  );

  void back<T>([T? result]) {
    if (_navigator.canPop()) _navigator.pop<T>(result);
  }

  void popUntil(RoutePredicate predicate) => _navigator.popUntil(predicate);

  bool canPop() => _navigator.canPop();

  // ── Named Routes ──────────────────────────────────────────────────────────

  Future<T?> toNamed<T>(String name, {Object? arguments}) =>
      _navigator.pushNamed<T>(name, arguments: arguments);

  Future<T?> replaceNamed<T, R>(String name, {R? result, Object? arguments}) =>
      _navigator.pushReplacementNamed<T, R>(
        name,
        result: result,
        arguments: arguments,
      );

  Future<T?> offAllNamed<T>(String name, {Object? arguments}) => _navigator
      .pushNamedAndRemoveUntil<T>(name, (_) => false, arguments: arguments);
}
