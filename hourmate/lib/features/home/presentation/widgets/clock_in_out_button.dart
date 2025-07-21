import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/work_entry.dart';
import 'package:flutter/scheduler.dart';
import 'rounded_clock_timer.dart';
import '../../../work_log/presentation/widgets/rounded_gradient_button.dart';

class ClockInOutButton extends StatefulWidget {
  final bool isClockInEnabled;
  final WorkEntry? activeWorkEntry;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final bool isOnBreak; // NEW

  const ClockInOutButton({
    super.key,
    required this.isClockInEnabled,
    this.activeWorkEntry,
    required this.onClockIn,
    required this.onClockOut,
    required this.isOnBreak, // NEW
  });

  @override
  State<ClockInOutButton> createState() => _ClockInOutButtonState();
}

class _ClockInOutButtonState extends State<ClockInOutButton> {
  late final ValueNotifier<DateTime> _nowNotifier;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _nowNotifier = ValueNotifier(DateTime.now());
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration _) {
    _nowNotifier.value = DateTime.now();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _nowNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Clock Timer (moved to top)
          if (!widget.isClockInEnabled && widget.activeWorkEntry != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: RoundedClockTimer(
                startTime: widget.activeWorkEntry!.startTime,
                size: 180,
                showDigitalTime: true,
                showSeconds: true,
              ),
            ),

          // Clock In/Out Button
          if (widget.isClockInEnabled)
            // Clock In Button (simplified style)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(32),
              child: InkWell(
                onTap: widget.isOnBreak
                    ? null
                    : widget.onClockIn, // DISABLE if on break
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isOnBreak
                        ? AppTheme.disabledTextColor.withValues(alpha: 0.2)
                        : AppTheme.tabBarBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: widget.isOnBreak
                                ? [
                                    AppTheme.disabledTextColor.withValues(
                                      alpha: 0.2,
                                    ), // Cyan
                                    AppTheme.disabledTextColor.withValues(
                                      alpha: 0.5,
                                    ), // Neon yellow-green
                                  ]
                                : [
                                    AppTheme.headerGradientEnd, // Cyan
                                    AppTheme
                                        .headerGradientStart, // Neon yellow-green
                                  ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.progressStart,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Clock In',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Clock Out Button (using reusable button style)
            RoundedGradientButton(
              text: 'Clock Out',
              onPressed: widget.onClockOut,
              height: 45, // Made smaller
            ),

          // Active session info
          if (!widget.isClockInEnabled && widget.activeWorkEntry != null) ...[
            const SizedBox(height: 12),
            Text(
              'Active since ${DateFormat(AppConstants.timeFormat).format(widget.activeWorkEntry!.startTime)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
