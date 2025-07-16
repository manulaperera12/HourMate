import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/work_entry.dart';

class WorkStatusCard extends StatefulWidget {
  final WorkEntry workEntry;

  const WorkStatusCard({super.key, required this.workEntry});

  @override
  State<WorkStatusCard> createState() => _WorkStatusCardState();
}

class _WorkStatusCardState extends State<WorkStatusCard> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration duration = _currentTime.difference(
      widget.workEntry.startTime,
    );
    final String formattedDuration =
        '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.disabledTextColor.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppTheme.goodRatingColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Currently Working',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.goodRatingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Task Description
            Text(
              widget.workEntry.taskDescription,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            // Duration
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Duration: $formattedDuration',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'Started at ${DateFormat(AppConstants.timeFormat).format(widget.workEntry.startTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.disabledTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
