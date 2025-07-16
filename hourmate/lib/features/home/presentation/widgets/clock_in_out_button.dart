import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/work_entry.dart';

class ClockInOutButton extends StatelessWidget {
  final bool isClockInEnabled;
  final WorkEntry? activeWorkEntry;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;

  const ClockInOutButton({
    super.key,
    required this.isClockInEnabled,
    this.activeWorkEntry,
    required this.onClockIn,
    required this.onClockOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160, // Reduce from 200 to 160 to prevent overflow
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: isClockInEnabled ? onClockIn : onClockOut,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.progressStart, AppTheme.progressEnd],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.progressEnd.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isClockInEnabled
                        ? Icons.play_arrow_rounded
                        : Icons.stop_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Text
                Text(
                  isClockInEnabled ? 'Clock In' : 'Clock Out',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                // Active session info
                if (!isClockInEnabled && activeWorkEntry != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Active since ${DateFormat(AppConstants.timeFormat).format(activeWorkEntry!.startTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
