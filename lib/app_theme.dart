import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: const Color.fromRGBO(134, 200, 194, 1), // Primary color
        secondary: const Color(0xFF7BEEFF), // Background color
        surface: Colors.grey.shade900, // Surface color
        onPrimary: Colors.white, // Text color on primary
        onSecondary: Colors.white, // Text color on background
        onSurface: Colors.white70, // Text color on surface
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF06A0B5), // Button background color
        textTheme: ButtonTextTheme.primary, // Button text color
      ),
    );
  }

  // You can add more themes here if needed
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color.fromRGBO(134, 200, 194, 1),
        secondary: const Color(0xFF7BEEFF),
        surface: Colors.grey.shade100,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF06A0B5),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
