import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return StorageService.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    StorageService.setDarkMode(next == ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    StorageService.setDarkMode(mode == ThemeMode.dark);
  }
}
