import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RoundedGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool enabled;

  const RoundedGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.headerGradientEnd, // Cyan
                AppTheme.headerGradientStart, // Neon yellow-green
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.headerGradientStart.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Asap',
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
