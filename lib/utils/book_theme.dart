import 'package:flutter/material.dart';
import 'theme_colors.dart';

class BookTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ThemeColors.limeGreen,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        surfaceTintColor: ThemeColors.teal,

        // AppBar color
        iconTheme: IconThemeData(color: ThemeColors.teal),
        titleTextStyle: TextStyle(
          color: ThemeColors.teal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: ThemeColors.brickRed, // Button background color
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ThemeColors.teal,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ThemeColors.teal,
      ),
      colorScheme: const ColorScheme.light(
        primary: ThemeColors.teal,
        secondary: ThemeColors.teal,
        error: ThemeColors.brickRed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: ThemeColors.teal,
      scaffoldBackgroundColor: const Color.fromARGB(255, 45, 39, 32),
      appBarTheme: const AppBarTheme(
        color: ThemeColors.brown, // AppBar color
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: ThemeColors.limeGreen, // Button background color
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ThemeColors.brown,
        contentTextStyle: TextStyle(color: Colors.black),
        actionBackgroundColor: ThemeColors.teal,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ThemeColors.teal,
      ),
      colorScheme: const ColorScheme.dark(
        primary: ThemeColors.teal,
        secondary: Colors.white,
        error: ThemeColors.brickRed,
        background: ThemeColors.brown,
        onPrimary: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}
