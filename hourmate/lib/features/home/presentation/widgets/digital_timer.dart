import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/theme/app_theme.dart';

class DigitalTimer extends StatefulWidget {
  final DateTime startTime;
  final double fontSize;
  final bool showSeconds;
  final Color? textColor;

  const DigitalTimer({
    super.key,
    required this.startTime,
    this.fontSize = 24,
    this.showSeconds = true,
    this.textColor,
  });

  @override
  State<DigitalTimer> createState() => _DigitalTimerState();
}

class _DigitalTimerState extends State<DigitalTimer>
    with TickerProviderStateMixin {
  late final ValueNotifier<DateTime> _nowNotifier;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _nowNotifier = ValueNotifier(DateTime.now());
    _ticker = createTicker(_onTick)..start();
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
    return ValueListenableBuilder<DateTime>(
      valueListenable: _nowNotifier,
      builder: (context, now, _) {
        final duration = now.difference(widget.startTime);
        final hours = duration.inHours;
        final minutes = (duration.inMinutes % 60);
        final seconds = (duration.inSeconds % 60);

        final timeString = widget.showSeconds
            ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
            : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

        return Text(
          timeString,
          style: TextStyle(
            color: widget.textColor ?? AppTheme.neonYellowGreen,
            fontWeight: FontWeight.bold,
            fontSize: widget.fontSize,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
          ),
        );
      },
    );
  }
}
