import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ReminderState {
  final bool isEnabled;
  final int hour;
  final int minute;

  const ReminderState({
    required this.isEnabled,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  ReminderState copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
  }) {
    return ReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

final reminderProvider =
    NotifierProvider<ReminderNotifier, ReminderState>(ReminderNotifier.new);

class ReminderNotifier extends Notifier<ReminderState> {
  @override
  ReminderState build() {
    final enabled = StorageService.isRemindersEnabled();
    final hour = StorageService.getReminderHour();
    final minute = StorageService.getReminderMinute();

    // Schedule on app start if enabled
    if (enabled) {
      NotificationService.scheduleDailyReminder(hour: hour, minute: minute);
    }

    return ReminderState(
      isEnabled: enabled,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    await StorageService.setRemindersEnabled(enabled);

    if (enabled) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyReminder(
        hour: state.hour,
        minute: state.minute,
      );
    } else {
      await NotificationService.cancelDailyReminder();
    }
  }

  Future<void> setTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    await StorageService.setReminderTime(hour, minute);

    if (state.isEnabled) {
      await NotificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }
}
