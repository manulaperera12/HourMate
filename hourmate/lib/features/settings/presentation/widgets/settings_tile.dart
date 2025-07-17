import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTappable = onTap != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isTappable
                  ? AppTheme.surfaceColor.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppTheme.secondaryTextColor)
                        .withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTappable)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.secondaryTextColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
