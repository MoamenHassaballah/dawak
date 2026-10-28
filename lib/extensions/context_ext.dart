import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  Future<T?> push<T extends Object?>(Widget page) {
    return navigator.push<T>(MaterialPageRoute<T>(builder: (_) => page));
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return navigator.pushReplacement<T, TO>(
      MaterialPageRoute<T>(builder: (_) => page),
      result: result,
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget page,
    RoutePredicate predicate,
  ) {
    return navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(builder: (_) => page),
      predicate,
    );
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator.popAndPushNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  Future<bool> maybePop<T extends Object?>([T? result]) {
    return navigator.maybePop<T>(result);
  }

  bool get canPop => navigator.canPop();

  void pop<T extends Object?>([T? result]) {
    navigator.pop<T>(result);
  }

  void popUntil(RoutePredicate predicate) {
    navigator.popUntil(predicate);
  }
}
