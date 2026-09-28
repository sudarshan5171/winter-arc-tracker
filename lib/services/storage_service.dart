import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/winter_arc_model.dart';
import '../models/goal_model.dart';
import '../models/daily_entry_model.dart';

class StorageService {
  static const String arcBoxName = 'winter_arc_box';
  static const String goalsBoxName = 'goals_box';
  static const String entriesBoxName = 'entries_box';
  static const String settingsBoxName = 'settings_box';

  static late Box<String> _arcBox;
  static late Box<String> _goalsBox;
  static late Box<String> _entriesBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _arcBox = await Hive.openBox<String>(arcBoxName);
    _goalsBox = await Hive.openBox<String>(goalsBoxName);
    _entriesBox = await Hive.openBox<String>(entriesBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
  }

  static bool get isInitialized =>
      Hive.isBoxOpen(arcBoxName) &&
      Hive.isBoxOpen(goalsBoxName) &&
      Hive.isBoxOpen(entriesBoxName) &&
      Hive.isBoxOpen(settingsBoxName);

  // --- Winter Arc ---
  static WinterArc? getWinterArc() {
    if (!isInitialized) return null;
    final raw = _arcBox.get('current_arc');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WinterArc.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWinterArc(WinterArc arc) async {
    if (!isInitialized) return;
    await _arcBox.put('current_arc', jsonEncode(arc.toMap()));
  }

  // --- Goals ---
  static List<Goal> getGoals() {
    if (!isInitialized) return [];
    final list = <Goal>[];
    for (final raw in _goalsBox.values) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        list.add(Goal.fromMap(map));
      } catch (_) {}
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  static Future<void> saveGoal(Goal goal) async {
    if (!isInitialized) return;
    await _goalsBox.put(goal.id, jsonEncode(goal.toMap()));
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    if (!isInitialized) return;
    final entries = <String, String>{};
    for (final goal in goals) {
      entries[goal.id] = jsonEncode(goal.toMap());
    }
    await _goalsBox.putAll(entries);
  }

  static Future<void> deleteGoal(String goalId) async {
    if (!isInitialized) return;
    await _goalsBox.delete(goalId);
  }

  // --- Daily Entries ---
  static Map<String, DailyEntry> getDailyEntries() {
    if (!isInitialized) return {};
    final map = <String, DailyEntry>{};
    for (final key in _entriesBox.keys) {
      final raw = _entriesBox.get(key);
      if (raw != null) {
        try {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          final entry = DailyEntry.fromMap(data);
          map[entry.compositeKey] = entry;
        } catch (_) {}
      }
    }
    return map;
  }

  static Future<void> saveDailyEntry(DailyEntry entry) async {
    if (!isInitialized) return;
    await _entriesBox.put(entry.compositeKey, jsonEncode(entry.toMap()));
  }

  static Future<void> clearAllEntries() async {
    if (!isInitialized) return;
    await _entriesBox.clear();
  }

  // --- Settings / Theme ---
  static bool isDarkMode() {
    if (!isInitialized) return false;
    return _settingsBox.get('is_dark_mode', defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool isDark) async {
    if (!isInitialized) return;
    await _settingsBox.put('is_dark_mode', isDark);
  }

  // --- Reminders ---
  static bool isRemindersEnabled() {
    if (!isInitialized) return true;
    return _settingsBox.get('is_reminders_enabled', defaultValue: true) as bool;
  }

  static Future<void> setRemindersEnabled(bool enabled) async {
    if (!isInitialized) return;
    await _settingsBox.put('is_reminders_enabled', enabled);
  }

  static int getReminderHour() {
    if (!isInitialized) return 20; // 8:00 PM default
    return _settingsBox.get('reminder_hour', defaultValue: 20) as int;
  }

  static int getReminderMinute() {
    if (!isInitialized) return 0;
    return _settingsBox.get('reminder_minute', defaultValue: 0) as int;
  }

  static Future<void> setReminderTime(int hour, int minute) async {
    if (!isInitialized) return;
    await _settingsBox.put('reminder_hour', hour);
    await _settingsBox.put('reminder_minute', minute);
  }
}
