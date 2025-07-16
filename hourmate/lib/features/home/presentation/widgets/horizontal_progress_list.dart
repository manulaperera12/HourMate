import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';

class HorizontalProgressList extends StatelessWidget {
  // Placeholder/mock data for now
  final List<DayProgress> weekProgress;

  const HorizontalProgressList({super.key, required this.weekProgress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: weekProgress.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final day = weekProgress[index];
          return Container(
            // width: 68,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: AppTheme.disabledTextColor, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.progressEnd.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircularPercentIndicator(
                      radius: 28, // Reduce radius
                      lineWidth: 7, // Reduce line width
                      percent: day.percent,
                      animation: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: AppTheme.progressBg,
                      linearGradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.progressStart, AppTheme.progressEnd],
                      ),
                      center: Text(
                        '${(day.percent * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduce spacing
                  Text(
                    day.dayLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    day.dateLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.disabledTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DayProgress {
  final double percent; // 0.0 - 1.0
  final String dayLabel; // e.g., 'Mon'
  final String dateLabel; // e.g., '02'

  DayProgress({
    required this.percent,
    required this.dayLabel,
    required this.dateLabel,
  });
}
