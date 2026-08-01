import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(double fontSize) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 205, 174, 130),
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(bodyMedium: TextStyle(fontSize: fontSize)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 205, 174, 130),
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 205, 174, 130),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  static ThemeData dark(double fontSize) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 205, 174, 130),
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(bodyMedium: TextStyle(fontSize: fontSize)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 205, 174, 130),
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 205, 174, 130),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
