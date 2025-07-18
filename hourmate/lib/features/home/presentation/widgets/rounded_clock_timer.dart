import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class RoundedClockTimer extends StatefulWidget {
  final DateTime startTime;
  final double size;
  final bool showDigitalTime;
  final bool showSeconds;
  final bool showClockHands;

  const RoundedClockTimer({
    super.key,
    required this.startTime,
    this.size = 120,
    this.showDigitalTime = true,
    this.showSeconds = true,
    this.showClockHands = true,
  });

  @override
  State<RoundedClockTimer> createState() => _RoundedClockTimerState();
}

class _RoundedClockTimerState extends State<RoundedClockTimer>
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
        final totalSeconds = duration.inSeconds;
        final hours = duration.inHours;
        final minutes = (duration.inMinutes % 60);
        final seconds = (duration.inSeconds % 60);

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonYellowGreen.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppTheme.neonYellowGreen.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Clock face
              Center(
                child: Container(
                  width: widget.size - 20,
                  height: widget.size - 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.backgroundColor,
                    border: Border.all(
                      color: AppTheme.disabledTextColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),

              // Clock hands
              if (widget.showClockHands)
                Center(
                  child: SizedBox(
                    width: widget.size - 40,
                    height: widget.size - 40,
                    child: CustomPaint(
                      painter: ClockHandsPainter(
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                        totalSeconds: totalSeconds,
                        color: AppTheme.neonYellowGreen,
                      ),
                    ),
                  ),
                ),

              // Digital time display
              if (widget.showDigitalTime)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.neonYellowGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.showSeconds
                          ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                          : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: AppTheme.neonYellowGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.size * 0.12,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),

              // Pulsing animation
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Container(
                      width: widget.size + (value * 10),
                      height: widget.size + (value * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.neonYellowGreen.withValues(
                            alpha: (1 - value) * 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClockHandsPainter extends CustomPainter {
  final int hours;
  final int minutes;
  final int seconds;
  final int totalSeconds;
  final Color color;

  ClockHandsPainter({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalSeconds,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hour markers
    _drawHourMarkers(canvas, center, radius);

    // Draw hands
    _drawHands(canvas, center, radius);
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (3.14159 / 180);
      final startRadius = radius - 15;
      final endRadius = radius - 5;

      final startPoint = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );
      final endPoint = Offset(
        center.dx + endRadius * math.cos(angle - math.pi / 2),
        center.dy + endRadius * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    // Hour hand
    final hourAngle = ((hours % 12) * 30 + minutes * 0.5) * (3.14159 / 180);
    _drawHand(canvas, center, radius * 0.4, hourAngle, color, 4);

    // Minute hand
    final minuteAngle = (minutes * 6) * (3.14159 / 180);
    _drawHand(canvas, center, radius * 0.6, minuteAngle, color, 3);

    // Second hand
    final secondAngle = (seconds * 6) * (3.14159 / 180);
    _drawHand(canvas, center, radius * 0.7, secondAngle, color, 2);

    // Center dot
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    Color color,
    double width,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final endPoint = Offset(
      center.dx + length * math.cos(angle - math.pi / 2),
      center.dy + length * math.sin(angle - math.pi / 2),
    );

    canvas.drawLine(center, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
 