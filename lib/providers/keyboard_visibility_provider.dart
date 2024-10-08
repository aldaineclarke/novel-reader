import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeyboardVisibilityNotifier extends StateNotifier<bool>
    with WidgetsBindingObserver {
  KeyboardVisibilityNotifier() : super(false) {
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardVisibility();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardVisibility();
  }

  void _checkKeyboardVisibility() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    state = bottomInset > 0; // Update the state based on the bottom inset
  }
}

final keyboardVisibilityProvider =
    StateNotifierProvider<KeyboardVisibilityNotifier, bool>(
  (ref) => KeyboardVisibilityNotifier(),
);
