import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._internal();
  AppSettings._internal();

  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 18;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _fontSize = prefs.getDouble('fontSize') ?? 18;

    notifyListeners();
  }

  /// --- SETTERS ---
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', ThemeMode.values.indexOf(mode));
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', size);
  }

  getList(String s) {}

  Future<void> setList(String s, List<String> bookmarks) async {}
}
