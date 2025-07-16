import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';

class TodayProgressCircle extends StatelessWidget {
  final Duration worked;
  final Duration goal;

  const TodayProgressCircle({
    super.key,
    required this.worked,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (goal.inMinutes == 0)
        ? 0.0
        : (worked.inMinutes / goal.inMinutes).clamp(0.0, 1.0);
    final workedStr = _formatDuration(worked);
    final goalStr = _formatDuration(goal);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.progressEnd.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircularPercentIndicator(
            radius: 108,
            lineWidth: 24,
            percent: percent,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: AppTheme.progressBg,
            linearGradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.progressStart, AppTheme.progressEnd],
            ),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  workedStr,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'of $goalStr total',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
