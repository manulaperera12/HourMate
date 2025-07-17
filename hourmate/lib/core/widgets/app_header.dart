import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showShadow;
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.showShadow = true,
    this.onAvatarTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String _userAvatar = 'HM';

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatar = prefs.getString('user_avatar') ?? 'HM';
      if (mounted) {
        setState(() {
          _userAvatar = avatar;
        });
      }
    } catch (e) {
      // Keep default avatar if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: AppTheme.backgroundColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading widget (back button or custom leading)
          if (widget.showBackButton)
            GestureDetector(
              onTap: widget.onBack ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.neonYellowGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonYellowGreen.withValues(alpha: 0.10),
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
          else if (widget.leading != null)
            widget.leading!
          else
            // Default avatar
            GestureDetector(
              onTap: widget.onAvatarTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.neonYellowGreen,
                  child: Text(
                    _userAvatar,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 20),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryTextColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          if (widget.actions != null) ...[
            const SizedBox(width: 16),
            ...widget.actions!,
          ],
        ],
      ),
    );
  }
}
