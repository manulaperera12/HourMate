import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/productivity_calculator.dart';
import '../../domain/entities/work_entry.dart';

class ProductivityInsightsCard extends StatelessWidget {
  final List<WorkEntry> entries;
  final double dailyGoal;

  const ProductivityInsightsCard({
    super.key,
    required this.entries,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final insights = ProductivityCalculator.getProductivityInsights(
      entries,
      dailyGoal,
    );
    final score = (insights['score'] as num).toInt();
    final type = insights['type'] as String;
    final insightsList = insights['insights'] as List<String>;
    final breakdown = insights['breakdown'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF2C2C2C),
            const Color(0xFF1A1A1A).withValues(alpha: 0.5),
            const Color(0xFF0D0D0D).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppTheme.statOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Productivity Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.statOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$score',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                    ),
                    Text(
                      type,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getTypeColor(type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(score),
                      _getScoreColor(score).withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getScoreIcon(score),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Breakdown
          if (breakdown != null) ...[
            Text(
              'Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'Quality',
                    (breakdown['quality'] as num).toInt(),
                    Icons.star,
                    AppTheme.neonYellowGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBreakdownItem(
                    'Efficiency',
                    (breakdown['efficiency'] as num).toInt(),
                    Icons.trending_up,
                    AppTheme.cyanBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'Consistency',
                    (breakdown['consistency'] as num).toInt(),
                    Icons.repeat,
                    AppTheme.statBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBreakdownItem(
                    'Focus',
                    (breakdown['focus'] as num).toInt(),
                    Icons.psychology,
                    AppTheme.statOrange,
                  ),
                ),
              ],
            ),
          ],

          // Insights
          if (insightsList.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...insightsList.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.neonYellowGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            '$value%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'exceptional':
        return AppTheme.neonYellowGreen;
      case 'excellent':
        return AppTheme.cyanBlue;
      case 'good':
        return AppTheme.statBlue;
      case 'average':
        return AppTheme.statOrange;
      case 'needs improvement':
        return AppTheme.errorColor;
      default:
        return AppTheme.secondaryTextColor;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppTheme.neonYellowGreen;
    if (score >= 80) return AppTheme.cyanBlue;
    if (score >= 70) return AppTheme.statBlue;
    if (score >= 60) return AppTheme.statOrange;
    return AppTheme.errorColor;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 80) return Icons.star;
    if (score >= 70) return Icons.thumb_up;
    if (score >= 60) return Icons.trending_up;
    return Icons.trending_down;
  }
}
