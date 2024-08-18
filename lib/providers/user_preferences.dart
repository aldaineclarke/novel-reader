// Obtain shared preferences.
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static setPreferences(SettingsOptions settingOptions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save an integer value to 'counter' key.
    await prefs.setBool('showBottomNav', settingOptions.showBottomNav);
    // Save an boolean value to 'repeat' key.
    await prefs.setBool('darkMode', settingOptions.darkMode);
    // Save an double value to 'decimal' key.
    await prefs.setBool('showExploreTab', settingOptions.showExploreTab);
  }
}

class SettingsOptions {
  final bool showBottomNav = false;
  final bool darkMode = false;
  final bool showExploreTab = false;
}
