import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RoundedGradientHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  const RoundedGradientHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, left: 12, right: 12, bottom: 12),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.headerGradientStart,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.headerGradientStart.withOpacity(0.10),
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
            const SizedBox(width: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Asap',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 52), // To balance the back button
        ],
      ),
    );
  }
}
