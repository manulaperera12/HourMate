import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BreakTimerCard extends StatelessWidget {
  final bool isOnBreak;
  final int? breakDurationMinutes;
  final int breakElapsedSeconds;
  final int breakRemainingSeconds;
  final int defaultDuration;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onStartBreak;
  final VoidCallback onEndBreak;

  const BreakTimerCard({
    super.key,
    required this.isOnBreak,
    required this.breakDurationMinutes,
    required this.breakElapsedSeconds,
    required this.breakRemainingSeconds,
    required this.defaultDuration,
    required this.onDurationChanged,
    required this.onStartBreak,
    required this.onEndBreak,
  });

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.tabBarBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: isOnBreak
            ? _buildActiveBreak(context)
            : _buildStartBreak(context),
      ),
    );
  }

  Widget _buildStartBreak(BuildContext context) {
    final double sliderValue = defaultDuration.clamp(5, 30).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppTheme.neonYellowGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Take a Break',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.neonYellowGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Set break duration:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: sliderValue,
                min: 5,
                max: 30,
                divisions: 5,
                label: '${sliderValue.round()} min',
                onChanged: (v) => onDurationChanged(v.round()),
                activeColor: AppTheme.neonYellowGreen,
                inactiveColor: AppTheme.neonYellowGreen.withOpacity(0.2),
              ),
            ),
            Text(
              '${sliderValue.round()} min',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.neonYellowGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonYellowGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onStartBreak,
            child: const Text(
              'Start Break',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBreak(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppTheme.cyanBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'On Break',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.cyanBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elapsed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                Text(
                  _formatDuration(breakElapsedSeconds),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                Text(
                  _formatDuration(breakRemainingSeconds),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.cyanBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyanBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onEndBreak,
            child: const Text(
              'End Break',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
