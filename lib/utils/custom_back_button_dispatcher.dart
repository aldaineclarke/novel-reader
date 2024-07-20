import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButtonDispatcher extends RootBackButtonDispatcher {
  CustomBackButtonDispatcher(this._routerDelegate);
  final GoRouterDelegate _routerDelegate;

  @override
  Future<bool> didPopRoute() async {
    final navigatorState = _routerDelegate.navigatorKey.currentState;
    if (kDebugMode) {
      print('Navigation State: $navigatorState');
    }
    if (navigatorState != null && navigatorState.canPop()) {
      navigatorState.pop();
      return true;
    }
    return super.didPopRoute();
  }
}
