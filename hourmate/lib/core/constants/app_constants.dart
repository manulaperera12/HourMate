class AppConstants {
  // App Info
  static const String appName = 'HourMate';
  static const String appVersion = '1.0.0';

  // Task Rating Options
  static const String goodRating = 'Good';
  static const String averageRating = 'Average';
  static const String badRating = 'Bad';

  static const List<String> taskRatingOptions = [
    goodRating,
    averageRating,
    badRating,
  ];

  // Storage Keys
  static const String workEntriesKey = 'work_entries';
  static const String settingsKey = 'settings';
  static const String userNameKey = 'user_name';
  static const String companyNameKey = 'company_name';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Time Formats
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String weekFormat = 'MMM dd';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation
  static const int maxTaskDescriptionLength = 200;
  static const int maxCommentLength = 500;

  // PDF Export
  static const String pdfFileName = 'hourmate_timesheet';
  static const String pdfTitle = 'Weekly Timesheet';

  // Navigation
  static const String homeRoute = '/';
  static const String workLogRoute = '/work-log';
  static const String weeklySummaryRoute = '/weekly-summary';
  static const String settingsRoute = '/settings';
}
