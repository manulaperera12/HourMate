import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementUnlockedPopup extends StatefulWidget {
  final String achievementName;
  const AchievementUnlockedPopup({super.key, required this.achievementName});

  @override
  State<AchievementUnlockedPopup> createState() =>
      _AchievementUnlockedPopupState();
}

class _AchievementUnlockedPopupState extends State<AchievementUnlockedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.cyanBlue, AppTheme.neonYellowGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonYellowGreen.withOpacity(0.25),
                blurRadius: 32,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.cyanBlue,
                size: 64,
              ),
              const SizedBox(height: 18),
              Text(
                'Achievement Unlocked!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.achievementName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neonYellowGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.black,
                  foregroundColor: AppTheme.neonYellowGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
