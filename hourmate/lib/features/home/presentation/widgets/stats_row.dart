import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  final String hoursWorked;
  final int tasksDone;
  final int productivityScore;

  const StatsRow({
    super.key,
    required this.hoursWorked,
    required this.tasksDone,
    required this.productivityScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tabBarBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatCard(
              icon: Icons.access_time,
              iconColor: AppTheme.statYellow,
              value: hoursWorked,
              label: 'Hours Worked',
            ),
            _StatCard(
              icon: Icons.check_circle,
              iconColor: AppTheme.statBlue,
              value: '$tasksDone',
              label: 'Tasks Done',
            ),
            _StatCard(
              icon: Icons.star,
              iconColor: AppTheme.statOrange,
              value: '+$productivityScore',
              label: 'Productivity',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
