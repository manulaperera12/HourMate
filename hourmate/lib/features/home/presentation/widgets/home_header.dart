import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';

class HomeHeader extends StatelessWidget {
  final String dateRange;
  final VoidCallback? onSettingsTap;
  final bool showBackButton;
  final VoidCallback? onBack;

  const HomeHeader({
    super.key,
    required this.dateRange,
    this.onSettingsTap,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: 'My Progress',
      subtitle: dateRange,
      showBackButton: showBackButton,
      onBack: onBack,
      actions: onSettingsTap != null
          ? [
              Material(
                color: AppTheme.neonYellowGreen,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSettingsTap,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.settings,
                      color: AppTheme.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}
