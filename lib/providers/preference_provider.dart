import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider() {
    _loadPreferences();
  }
  double _fontSize = 14.0;
  Color _fontColor = Colors.black;
  Color _backgroundColor = Colors.white;
  ScrollDirection _scrollDirection = ScrollDirection.vertical;

  double get fontSize => _fontSize;
  Color get fontColor => _fontColor;
  Color get backgroundColor => _backgroundColor;
  ScrollDirection get scrollDirection => _scrollDirection;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('font_size') ?? 16.0;
    _fontColor = Color(prefs.getInt('font_color') ?? Colors.black.value);
    _backgroundColor =
        Color(prefs.getInt('background_color') ?? Colors.white.value);
    final scrollDirectionEnumIndex = prefs.getInt('scrollDirection');
    _scrollDirection =
        (scrollDirectionEnumIndex != null) // check if an entry exists
            ? (prefs.getInt('scroll_direction') == 0)
                ? ScrollDirection.vertical
                : ScrollDirection.horizontal
            : ScrollDirection.vertical;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = size;
    await prefs.setDouble('font_size', size);
    notifyListeners();
  }

  Future<void> setFontColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _fontColor = color;
    await prefs.setInt('font_color', color.value);
    notifyListeners();
  }

  Future<void> setScrollDirection(ScrollDirection scrollDirection) async {
    final prefs = await SharedPreferences.getInstance();
    _scrollDirection = scrollDirection;
    await prefs.setInt('scroll_direction', scrollDirection.index);
    notifyListeners();
  }

  Future<void> setBackgroundColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _backgroundColor = color;
    await prefs.setInt('background_color', color.value);
    notifyListeners();
  }
}

// Finally, we are using ChangeNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final preferenceProvider = ChangeNotifierProvider<PreferencesProvider>((ref) {
  return PreferencesProvider();
});

enum ScrollDirection { vertical, horizontal }
