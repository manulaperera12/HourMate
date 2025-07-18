import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsService {
  static const String _workStartTimeKey = 'work_start_time';
  static const String _workEndTimeKey = 'work_end_time';
  static const String _breakDurationKey = 'break_duration';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _themeModeKey = 'theme_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _autoClockOutKey = 'auto_clock_out';
  static const String _autoClockOutDurationKey = 'auto_clock_out_duration';
  static const String _weeklyGoalKey = 'weekly_goal';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _customGoalsKey = 'custom_goals';
  static const String _weeklyGoalDaysKey = 'weekly_goal_days';
  static const String _breaksKey = 'breaks';
  static const String _breakEndSoundKey = 'break_end_sound';

  // Work Settings
  static Future<String> getWorkStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workStartTimeKey) ?? '09:00';
  }

  static Future<void> setWorkStartTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workStartTimeKey, time);
  }

  static Future<String> getWorkEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workEndTimeKey) ?? '17:00';
  }

  static Future<void> setWorkEndTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workEndTimeKey, time);
  }

  static Future<int> getBreakDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_breakDurationKey) ?? 60; // minutes
  }

  static Future<void> setBreakDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_breakDurationKey, minutes);
  }

  // Notification Settings
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  static Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  // Auto Clock Out Settings
  static Future<bool> getAutoClockOutEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoClockOutKey) ?? false;
  }

  static Future<void> setAutoClockOutEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoClockOutKey, enabled);
  }

  static Future<int> getAutoClockOutDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoClockOutDurationKey) ?? 8; // hours
  }

  static Future<void> setAutoClockOutDuration(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoClockOutDurationKey, hours);
  }

  // Goals
  static Future<double> getWeeklyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_weeklyGoalKey) ?? 40.0; // hours
  }

  static Future<void> setWeeklyGoal(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weeklyGoalKey, hours);
  }

  static Future<double> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_dailyGoalKey) ?? 8.0; // hours
  }

  static Future<void> setDailyGoal(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_dailyGoalKey, hours);
    // Also update weekly goal based on weekly_goal_days
    final days = await getWeeklyGoalDays();
    await setWeeklyGoal(hours * days);
  }

  // Custom Goals/Tasks
  static Future<List<Map<String, dynamic>>> getCustomGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getStringList(_customGoalsKey) ?? [];
    return goalsJson
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> addCustomGoal(
    String title, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getCustomGoals();
    goals.add({
      'title': title,
      'completed': false,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });
    await prefs.setStringList(
      _customGoalsKey,
      goals.map((g) => json.encode(g)).toList(),
    );
  }

  static Future<void> updateCustomGoal(
    int index, {
    String? title,
    bool? completed,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getCustomGoals();
    if (index >= 0 && index < goals.length) {
      if (title != null) goals[index]['title'] = title;
      if (completed != null) goals[index]['completed'] = completed;
      if (startDate != null)
        goals[index]['startDate'] = startDate.toIso8601String();
      if (endDate != null) goals[index]['endDate'] = endDate.toIso8601String();
      await prefs.setStringList(
        _customGoalsKey,
        goals.map((g) => json.encode(g)).toList(),
      );
    }
  }

  static Future<void> removeCustomGoal(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getCustomGoals();
    if (index >= 0 && index < goals.length) {
      goals.removeAt(index);
      await prefs.setStringList(
        _customGoalsKey,
        goals.map((g) => json.encode(g)).toList(),
      );
    }
  }

  // Theme Settings
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system'; // system, light, dark
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  static Future<int> getWeeklyGoalDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weeklyGoalDaysKey) ?? 5;
  }

  static Future<void> setWeeklyGoalDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weeklyGoalDaysKey, days);
    // Recalculate weekly goal if daily goal is set
    final dailyGoal = await getDailyGoal();
    await setWeeklyGoal(dailyGoal * days);
  }

  static Future<void> startBreak(DateTime start, int durationMinutes) async {
    print(
      'Starting break at ' +
          start.toString() +
          ' for ' +
          durationMinutes.toString() +
          ' minutes',
    );
    final prefs = await SharedPreferences.getInstance();
    final breaks = await getAllBreaksRaw();
    breaks.add({
      'date': start.toIso8601String().substring(0, 10),
      'startTime': start.toIso8601String(),
      'endTime': null,
      'duration': durationMinutes,
    });
    await prefs.setStringList(
      _breaksKey,
      breaks.map((b) => json.encode(b)).toList(),
    );
    // Store active break info for timer restoration
    await prefs.setString('active_break_start', start.toIso8601String());
    await prefs.setInt('active_break_duration', durationMinutes);
  }

  static Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final breaks = await getAllBreaksRaw();
    for (int i = breaks.length - 1; i >= 0; i--) {
      if (breaks[i]['endTime'] == null) {
        breaks[i]['endTime'] = DateTime.now().toIso8601String();
        break;
      }
    }
    await prefs.setStringList(
      _breaksKey,
      breaks.map((b) => json.encode(b)).toList(),
    );
    // Remove active break info
    await prefs.remove('active_break_start');
    await prefs.remove('active_break_duration');
  }

  static Future<Map<String, dynamic>?> getActiveBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString('active_break_start');
    final duration = prefs.getInt('active_break_duration');
    print(
      'getActiveBreak: startStr=' +
          startStr.toString() +
          ', duration=' +
          duration.toString(),
    );
    if (startStr != null && duration != null) {
      final start = DateTime.tryParse(startStr);
      if (start != null) {
        return {'start': start, 'duration': duration};
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllBreaksRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final breaksJson = prefs.getStringList(_breaksKey) ?? [];
    return breaksJson
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getBreaksForDate(
    DateTime date,
  ) async {
    final breaks = await getAllBreaksRaw();
    final dateStr = date.toIso8601String().substring(0, 10);
    return breaks.where((b) => b['date'] == dateStr).toList();
  }

  static Future<bool> isBreakActive() async {
    final breaks = await getAllBreaksRaw();
    return breaks.any((b) => b['endTime'] == null);
  }

  static Future<String> getBreakEndSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_breakEndSoundKey) ?? 'chime.mp3';
  }

  static Future<void> setBreakEndSound(String soundFile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_breakEndSoundKey, soundFile);
  }

  // Get all settings as a map
  static Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'workStartTime': await getWorkStartTime(),
      'workEndTime': await getWorkEndTime(),
      'breakDuration': await getBreakDuration(),
      'notificationsEnabled': await getNotificationsEnabled(),
      'soundEnabled': await getSoundEnabled(),
      'vibrationEnabled': await getVibrationEnabled(),
      'autoClockOutEnabled': await getAutoClockOutEnabled(),
      'autoClockOutDuration': await getAutoClockOutDuration(),
      'weeklyGoal': await getWeeklyGoal(),
      'dailyGoal': await getDailyGoal(),
      'themeMode': await getThemeMode(),
      'customGoals': await getCustomGoals(),
      'breakEndSound': await getBreakEndSound(),
    };
  }

  // Reset all settings to defaults
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workStartTimeKey);
    await prefs.remove(_workEndTimeKey);
    await prefs.remove(_breakDurationKey);
    await prefs.remove(_notificationsEnabledKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_vibrationEnabledKey);
    await prefs.remove(_autoClockOutKey);
    await prefs.remove(_autoClockOutDurationKey);
    await prefs.remove(_weeklyGoalKey);
    await prefs.remove(_dailyGoalKey);
    await prefs.remove(_themeModeKey);
    await prefs.remove(_customGoalsKey);
    await prefs.remove(_breakEndSoundKey);
  }
}
