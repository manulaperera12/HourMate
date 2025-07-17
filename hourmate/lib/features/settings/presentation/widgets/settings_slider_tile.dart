import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NeonGradientSliderTrackShape extends SliderTrackShape {
  const NeonGradientSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    Offset? secondaryOffset,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      offset: offset,
    );

    // Paint the full gradient track
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.neonYellowGreen, AppTheme.cyanBlue],
      ).createShader(trackRect);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(3)),
      paint,
    );

    // Overlay inactive (disabled) track if needed
    if (!isEnabled) {
      final Paint inactivePaint = Paint()
        ..color = AppTheme.disabledTextColor.withOpacity(0.3);
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, Radius.circular(3)),
        inactivePaint,
      );
    }
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    Offset offset = Offset.zero,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 6.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class SettingsSliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.surfaceColor.withOpacity(0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  trackShape: const NeonGradientSliderTrackShape(),
                  thumbColor: Colors.white,
                  overlayColor: AppTheme.cyanBlue.withOpacity(0.15),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    min.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    max.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
