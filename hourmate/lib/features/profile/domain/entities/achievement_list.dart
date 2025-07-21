import 'package:flutter/material.dart';
import 'achievement.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementList {
  static final List<Achievement> all = [
    Achievement(
      key: 'early_bird',
      title: 'Early Bird',
      description: 'Start work before 8 AM for 7 days',
      iconKey: 'star',
      color: AppTheme.neonYellowGreen,
      unlocked: false,
      progress: 0.0,
    ),
    Achievement(
      key: 'focus_master',
      title: 'Focus Master',
      description: 'Complete 50 tasks with 90%+ productivity',
      iconKey: 'trophy',
      color: AppTheme.cyanBlue,
      unlocked: false,
      progress: 0.0,
    ),
    Achievement(
      key: 'consistency_king',
      title: 'Consistency King',
      description: 'Work 30 consecutive days',
      iconKey: 'fire',
      color: AppTheme.orange,
      unlocked: false,
      progress: 0.0,
    ),
    Achievement(
      key: 'task_crusher',
      title: 'Task Crusher',
      description: 'Complete 100 tasks in a month',
      iconKey: 'check',
      color: AppTheme.neonYellowGreen,
      unlocked: false,
      progress: 0.0,
    ),
  ];
}
