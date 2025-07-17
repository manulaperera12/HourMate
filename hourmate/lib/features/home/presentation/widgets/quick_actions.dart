import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onViewLog;
  final VoidCallback onViewSummary;

  const QuickActions({
    super.key,
    required this.onViewLog,
    required this.onViewSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.history,
            title: 'Work Log',
            subtitle: 'View all entries',
            onTap: onViewLog,
            color: AppTheme.statYellow,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.bar_chart,
            title: 'Summary',
            subtitle: 'Weekly overview',
            onTap: onViewSummary,
            color: AppTheme.statBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0, // Adjust radius to control the spread of the gradient
          colors: [
            Color(0xFF2C2C2C), // Dark grey for the center
            Color(
              0xFF1A1A1A,
            ).withValues(alpha: 0.5), // Slightly darker grey for the outer part
            Color(
              0xFF0D0D0D,
            ).withValues(alpha: 0.0), // Even darker, almost black for the edges
          ],
          stops: const [0.0, 0.5, 1.0], // Control where each color stops
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
