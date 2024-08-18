import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsOptionsProvider =
    StateNotifierProvider<SettingOptionsNotifier, SettingsOptions>(
        (ref) => SettingOptionsNotifier());

class SettingOptionsNotifier extends StateNotifier<SettingsOptions> {
  SettingOptionsNotifier() : super(SettingsOptions());

  Future<void> updateSetting(String key, bool value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(key, value);
  }

  updateDarkMode(bool val) {
    var newState = state;
    newState.darkMode = val;
    updateSetting('darkMode', val);
    updateState(newState);
  }

  void updateState(SettingsOptions newState) {
    state = SettingsOptions(
      darkMode: newState.darkMode,
    );
  }
}

class SettingsOptions {
  SettingsOptions({
    this.showBottomNav = false,
    this.darkMode = false,
    this.showExploreTab = false,
  });
  bool showBottomNav;
  bool darkMode;
  bool showExploreTab;
}
