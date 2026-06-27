import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/notification_service.dart';

class DailyReminderState {
  final bool isEnabled;
  final TimeOfDay time;

  const DailyReminderState({
    required this.isEnabled,
    required this.time,
  });

  DailyReminderState copyWith({
    bool? isEnabled,
    TimeOfDay? time,
  }) {
    return DailyReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }
}

class DailyReminderNotifier extends StateNotifier<DailyReminderState> {
  DailyReminderNotifier()
      : super(const DailyReminderState(
          isEnabled: false,
          time: TimeOfDay(hour: 20, minute: 0),
        )) {
    _loadSettings();
  }

  static const _keyEnabled = 'daily_reminder_enabled';
  static const _keyHour = 'daily_reminder_hour';
  static const _keyMinute = 'daily_reminder_minute';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_keyEnabled) ?? false;
    final hour = prefs.getInt(_keyHour) ?? 20;
    final minute = prefs.getInt(_keyMinute) ?? 0;

    state = DailyReminderState(
      isEnabled: isEnabled,
      time: TimeOfDay(hour: hour, minute: minute),
    );

    if (isEnabled) {
      await NotificationService().scheduleDailyReminder(
        hour: hour,
        minute: minute,
        isEnabled: true,
      );
    }
  }

  Future<void> toggleReminder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);

    state = state.copyWith(isEnabled: enabled);

    await NotificationService().scheduleDailyReminder(
      hour: state.time.hour,
      minute: state.time.minute,
      isEnabled: enabled,
    );
  }

  Future<void> updateTime(TimeOfDay newTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, newTime.hour);
    await prefs.setInt(_keyMinute, newTime.minute);

    state = state.copyWith(time: newTime);

    if (state.isEnabled) {
      await NotificationService().scheduleDailyReminder(
        hour: newTime.hour,
        minute: newTime.minute,
        isEnabled: true,
      );
    }
  }
}

final dailyReminderProvider =
    StateNotifierProvider<DailyReminderNotifier, DailyReminderState>((ref) {
  return DailyReminderNotifier();
});
