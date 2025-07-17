class AppSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool autoClockOutEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final double workGoalHours;
  final double breakReminderMinutes;
  final String themeMode; // 'light', 'dark', 'system'
  final String language; // 'en', 'es', 'fr', etc.
  final bool autoBackupEnabled;
  final String backupFrequency; // 'daily', 'weekly', 'monthly'

  const AppSettings({
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.autoClockOutEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.workGoalHours = 8.0,
    this.breakReminderMinutes = 30.0,
    this.themeMode = 'system',
    this.language = 'en',
    this.autoBackupEnabled = false,
    this.backupFrequency = 'weekly',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? autoClockOutEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? workGoalHours,
    double? breakReminderMinutes,
    String? themeMode,
    String? language,
    bool? autoBackupEnabled,
    String? backupFrequency,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      autoClockOutEnabled: autoClockOutEnabled ?? this.autoClockOutEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      workGoalHours: workGoalHours ?? this.workGoalHours,
      breakReminderMinutes: breakReminderMinutes ?? this.breakReminderMinutes,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'autoClockOutEnabled': autoClockOutEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'workGoalHours': workGoalHours,
      'breakReminderMinutes': breakReminderMinutes,
      'themeMode': themeMode,
      'language': language,
      'autoBackupEnabled': autoBackupEnabled,
      'backupFrequency': backupFrequency,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkModeEnabled: json['darkModeEnabled'] ?? true,
      autoClockOutEnabled: json['autoClockOutEnabled'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      workGoalHours: (json['workGoalHours'] ?? 8.0).toDouble(),
      breakReminderMinutes: (json['breakReminderMinutes'] ?? 30.0).toDouble(),
      themeMode: json['themeMode'] ?? 'system',
      language: json['language'] ?? 'en',
      autoBackupEnabled: json['autoBackupEnabled'] ?? false,
      backupFrequency: json['backupFrequency'] ?? 'weekly',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.notificationsEnabled == notificationsEnabled &&
        other.darkModeEnabled == darkModeEnabled &&
        other.autoClockOutEnabled == autoClockOutEnabled &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.workGoalHours == workGoalHours &&
        other.breakReminderMinutes == breakReminderMinutes &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.autoBackupEnabled == autoBackupEnabled &&
        other.backupFrequency == backupFrequency;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      darkModeEnabled,
      autoClockOutEnabled,
      soundEnabled,
      vibrationEnabled,
      workGoalHours,
      breakReminderMinutes,
      themeMode,
      language,
      autoBackupEnabled,
      backupFrequency,
    );
  }
}
