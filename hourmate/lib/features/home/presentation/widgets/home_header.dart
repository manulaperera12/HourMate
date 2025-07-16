import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String dateRange;
  final VoidCallback? onSettingsTap;
  final bool showBackButton;
  final VoidCallback? onBack;

  const HomeHeader({
    super.key,
    required this.dateRange,
    this.onSettingsTap,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.backgroundColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.neonYellowGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonYellowGreen.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.black,
                  size: 20,
                ),
              ),
            )
          else
            // Avatar with border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.neonYellowGreen,
                child: Text(
                  'HM',
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 20),
          // Title and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateRange,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryTextColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Settings icon in circular background
          Material(
            color: AppTheme.neonYellowGreen,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSettingsTap,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.settings, color: AppTheme.black, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
