import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WeeklySummaryContent extends StatelessWidget {
  const WeeklySummaryContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final totalHours = 32.5;
    final dailyHours = [6.0, 7.5, 5.0, 8.0, 6.0, 0.0, 0.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final ratings = {'Good': 8, 'Average': 3, 'Bad': 1};

    return Column(
      mainAxisSize: MainAxisSize.min, // Only take up as much space as needed
      children: [
        const SizedBox(height: 12),
        // Total hours
        Text(
          '${totalHours.toStringAsFixed(1)} h',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.neonYellowGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'Asap',
            fontSize: 38,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Total hours this week',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.secondaryTextColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        // Bar chart placeholder
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius:
                  1.0, // Adjust radius to control the spread of the gradient
              colors: [
                Color(0xFF2C2C2C), // Dark grey for the center
                Color(0xFF1A1A1A).withValues(
                  alpha: 0.5,
                ), // Slightly darker grey for the outer part
                Color(0xFF0D0D0D).withValues(
                  alpha: 0.0,
                ), // Even darker, almost black for the edges
              ],
              stops: const [0.0, 0.5, 1.0], // Control where each color stops
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonYellowGreen.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 16,
                    height: (dailyHours[i] / 8.0) * 60 + 8, // max 8h
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.headerGradientEnd,
                          AppTheme.headerGradientStart,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 28),
        // Task rating summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RatingChip(
                label: 'Good',
                count: ratings['Good']!,
                color: AppTheme.goodRatingColor,
                icon: Icons.sentiment_satisfied_alt_rounded,
              ),
              _RatingChip(
                label: 'Average',
                count: ratings['Average']!,
                color: AppTheme.averageRatingColor,
                icon: Icons.sentiment_neutral_rounded,
              ),
              _RatingChip(
                label: 'Bad',
                count: ratings['Bad']!,
                color: AppTheme.badRatingColor,
                icon: Icons.sentiment_dissatisfied_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18), // Use spacing instead of Spacer
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _RatingChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklySummaryScreen extends StatelessWidget {
  final bool showBackButton;
  const WeeklySummaryScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.headerGradientStart.withValues(alpha: 0.8),
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.5, 0.9, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              const WeeklySummaryContent(),
            ],
          ),
        ),
      ),
    );
  }
}
