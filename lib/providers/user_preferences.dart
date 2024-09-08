// Obtain shared preferences.
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> setPreferences(SettingsOptions settingOptions) async {
    final prefs = await SharedPreferences.getInstance();

    // Save an integer value to 'counter' key.
    await prefs.setBool('showBottomNav', settingOptions.showBottomNav);
    // Save an boolean value to 'repeat' key.
    await prefs.setBool('darkMode', settingOptions.darkMode);
    // Save an double value to 'decimal' key.
    await prefs.setBool('showExploreTab', settingOptions.showExploreTab);
    await prefs.setInt('scrollDirection', settingOptions.scrollDirection.index);
  }
}

class SettingsOptions {
  final bool showBottomNav = false;
  final bool darkMode = false;
  final bool showExploreTab = false;
  final ScrollDirection scrollDirection = ScrollDirection.vertical;
}

enum ScrollDirection { vertical, horizontal }
