import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'transition_type.dart';

/// Enterprise Navigation API
/// Usage: Navigation.to(HomeView())
/// Usage: Navigation.replace(LoginView())
/// Usage: Navigation.offAll(MainView())
/// Usage: Navigation.back()
abstract final class Navigation {
  static final _service = NavigationService.instance;

  /// The key to attach to MaterialApp
  static GlobalKey<NavigatorState> get key => _service.navigatorKey;

  // ── Widget-based navigation ───────────────────────────────────────────────

  /// Push: Navigation.to(HomeView())
  static Future<T?> to<T>(
    Widget page, {
    TransitionType transition = TransitionType.slide,
  }) => _service.push<T>(page, transition: transition);

  /// Replace current: Navigation.replace(HomeView())
  static Future<T?> replace<T, R>(
    Widget page, {
    TransitionType transition = TransitionType.slide,
    R? result,
  }) => _service.replace<T, R>(page, transition: transition, result: result);

  /// Clear stack + go to: Navigation.offAll(MainView())
  static Future<T?> offAll<T>(
    Widget page, {
    TransitionType transition = TransitionType.fade,
  }) => _service.offAll<T>(page, transition: transition);

  /// Push and remove until predicate
  static Future<T?> offUntil<T>(
    Widget page,
    RoutePredicate predicate, {
    TransitionType transition = TransitionType.slide,
  }) => _service.offUntil<T>(page, predicate, transition: transition);

  // ── Pop ───────────────────────────────────────────────────────────────────

  /// Navigation.back()
  static void back<T>([T? result]) => _service.back<T>(result);

  static void popUntil(RoutePredicate predicate) =>
      _service.popUntil(predicate);

  static bool canPop() => _service.canPop();

  // ── Named Routes ──────────────────────────────────────────────────────────

  static Future<T?> toNamed<T>(String name, {Object? arguments}) =>
      _service.toNamed<T>(name, arguments: arguments);

  static Future<T?> replaceNamed<T, R>(
    String name, {
    R? result,
    Object? arguments,
  }) => _service.replaceNamed<T, R>(name, result: result, arguments: arguments);

  static Future<T?> offAllNamed<T>(String name, {Object? arguments}) =>
      _service.offAllNamed<T>(name, arguments: arguments);
}
