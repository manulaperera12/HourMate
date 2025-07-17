import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileAchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const ProfileAchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = achievement['unlocked'] as bool;
    final double progress = achievement['progress'] as double;
    final Color color = achievement['color'] as Color;
    final IconData icon = achievement['icon'] as IconData;
    final String title = achievement['title'] as String;
    final String description = achievement['description'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.3)
              : AppTheme.disabledTextColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.13)
                  : AppTheme.disabledTextColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : AppTheme.disabledTextColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isUnlocked
                                  ? AppTheme.primaryTextColor
                                  : AppTheme.disabledTextColor,
                            ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(Icons.check_circle_rounded, color: color, size: 20)
                    else
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? AppTheme.secondaryTextColor
                        : AppTheme.disabledTextColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.disabledTextColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
