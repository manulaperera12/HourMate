import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/work_entry.dart';
import 'package:flutter/scheduler.dart';

class ClockInOutButton extends StatefulWidget {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: widget.isClockInEnabled ? widget.onClockIn : widget.onClockOut,
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
                        color: AppTheme.progressEnd.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isClockInEnabled
                        ? Icons.play_arrow_rounded
                        : Icons.stop_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Text
                Text(
                  widget.isClockInEnabled ? 'Clock In' : 'Clock Out',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                // Live timer
                if (!widget.isClockInEnabled && widget.activeWorkEntry != null)
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _nowNotifier,
                    builder: (context, now, _) {
                      final duration = now.difference(
                        widget.activeWorkEntry!.startTime,
                      );
                      final hours = duration.inHours.toString().padLeft(2, '0');
                      final minutes = (duration.inMinutes % 60)
                          .toString()
                          .padLeft(2, '0');
                      final seconds = (duration.inSeconds % 60)
                          .toString()
                          .padLeft(2, '0');
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$hours:$minutes:$seconds',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                        ),
                      );
                    },
                  ),
                // Active session info
                if (!widget.isClockInEnabled &&
                    widget.activeWorkEntry != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Active since ${DateFormat(AppConstants.timeFormat).format(widget.activeWorkEntry!.startTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
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
