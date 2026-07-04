import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class AppSettingsViewModel extends ChangeNotifier {
  AppSettingsViewModel(this._storage) {
    _darkMode = _storage.isDarkMode;
  }

  final StorageService _storage;

  late bool _darkMode;

  bool get isDarkMode => _darkMode;

  ThemeMode get themeMode =>
      _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _darkMode = !_darkMode;
    await _storage.setDarkMode(_darkMode);
    notifyListeners();
  }

  Future<void> setGuestEntered() async {
    await _storage.setGuestEntered(true);
    notifyListeners();
  }

  bool get guestEntered => _storage.guestEntered;
}
