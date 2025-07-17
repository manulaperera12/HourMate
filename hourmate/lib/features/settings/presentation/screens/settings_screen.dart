import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_slider_tile.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBackButton;

  const SettingsScreen({super.key, this.showBackButton = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoClockOutEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _workGoalHours = 8.0;
  double _breakReminderMinutes = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.headerGradientStart.withValues(alpha: 0.8),
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
            ],
            stops: const [0.0, 0.3, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AppHeader(
                title: 'Settings',
                subtitle: 'Customize your HourMate experience',
                showBackButton: widget.showBackButton,
                onAvatarTap: _navigateToProfile,
              ),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Work Settings
                      SettingsSection(
                        title: 'Work Settings',
                        icon: Icons.work_rounded,
                        color: AppTheme.neonYellowGreen,
                        children: [
                          SettingsSliderTile(
                            title: 'Daily Work Goal',
                            subtitle:
                                '${_workGoalHours.toStringAsFixed(1)} hours',
                            value: _workGoalHours,
                            min: 1.0,
                            max: 12.0,
                            divisions: 22,
                            onChanged: (value) {
                              setState(() {
                                _workGoalHours = value;
                              });
                            },
                          ),
                          SettingsSwitchTile(
                            title: 'Auto Clock Out',
                            subtitle: 'Automatically clock out after 8 hours',
                            value: _autoClockOutEnabled,
                            onChanged: (value) {
                              setState(() {
                                _autoClockOutEnabled = value;
                              });
                            },
                          ),
                          SettingsSliderTile(
                            title: 'Break Reminder',
                            subtitle:
                                '${_breakReminderMinutes.round()} minutes',
                            value: _breakReminderMinutes,
                            min: 15.0,
                            max: 120.0,
                            divisions: 21,
                            onChanged: (value) {
                              setState(() {
                                _breakReminderMinutes = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Notifications
                      SettingsSection(
                        title: 'Notifications',
                        icon: Icons.notifications_rounded,
                        color: AppTheme.cyanBlue,
                        children: [
                          SettingsSwitchTile(
                            title: 'Enable Notifications',
                            subtitle: 'Receive work session reminders',
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                          SettingsSwitchTile(
                            title: 'Sound',
                            subtitle: 'Play notification sounds',
                            value: _soundEnabled,
                            onChanged: (value) {
                              setState(() {
                                _soundEnabled = value;
                              });
                            },
                          ),
                          SettingsSwitchTile(
                            title: 'Vibration',
                            subtitle: 'Vibrate on notifications',
                            value: _vibrationEnabled,
                            onChanged: (value) {
                              setState(() {
                                _vibrationEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Appearance
                      SettingsSection(
                        title: 'Appearance',
                        icon: Icons.palette_rounded,
                        color: AppTheme.orange,
                        children: [
                          SettingsSwitchTile(
                            title: 'Dark Mode',
                            subtitle: 'Use dark theme',
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                          ),
                          SettingsTile(
                            title: 'Theme Colors',
                            subtitle: 'Customize app colors',
                            icon: Icons.color_lens_rounded,
                            onTap: () {
                              // TODO: Navigate to theme customization
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Data & Privacy
                      SettingsSection(
                        title: 'Data & Privacy',
                        icon: Icons.security_rounded,
                        color: AppTheme.neonYellowGreen,
                        children: [
                          SettingsTile(
                            title: 'Export Data',
                            subtitle: 'Download your work logs',
                            icon: Icons.download_rounded,
                            onTap: () {
                              // TODO: Implement data export
                            },
                          ),
                          SettingsTile(
                            title: 'Backup & Restore',
                            subtitle: 'Manage your data',
                            icon: Icons.backup_rounded,
                            onTap: () {
                              // TODO: Navigate to backup settings
                            },
                          ),
                          SettingsTile(
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            icon: Icons.privacy_tip_rounded,
                            onTap: () {
                              // TODO: Show privacy policy
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About
                      SettingsSection(
                        title: 'About',
                        icon: Icons.info_rounded,
                        color: AppTheme.cyanBlue,
                        children: [
                          SettingsTile(
                            title: 'App Version',
                            subtitle: '1.0.0',
                            icon: Icons.app_settings_alt_rounded,
                            onTap: null,
                          ),
                          SettingsTile(
                            title: 'Terms of Service',
                            subtitle: 'Read our terms',
                            icon: Icons.description_rounded,
                            onTap: () {
                              // TODO: Show terms of service
                            },
                          ),
                          SettingsTile(
                            title: 'Support',
                            subtitle: 'Get help and contact us',
                            icon: Icons.support_agent_rounded,
                            onTap: () {
                              // TODO: Navigate to support
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Danger Zone
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [
                              const Color(0xFF2C2C2C),
                              const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                              const Color(0xFF0D0D0D).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor.withOpacity(
                                        0.13,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.warning_rounded,
                                      color: AppTheme.errorColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Danger Zone',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.errorColor,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Irreversible actions',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.secondaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: AppTheme.dividerColor,
                              height: 1,
                            ),
                            SettingsTile(
                              title: 'Clear All Data',
                              subtitle: 'Delete all work entries and settings',
                              icon: Icons.delete_forever_rounded,
                              iconColor: AppTheme.errorColor,
                              onTap: () {
                                _showClearDataDialog();
                              },
                            ),
                            SettingsTile(
                              title: 'Reset App',
                              subtitle: 'Reset to factory settings',
                              icon: Icons.restore_rounded,
                              iconColor: AppTheme.errorColor,
                              onTap: () {
                                _showResetAppDialog();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Data?',
          style: TextStyle(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all your work entries, settings, and app data. This action cannot be undone.',
          style: TextStyle(color: AppTheme.primaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear data
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text(
              'Clear Data',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset App?',
          style: TextStyle(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset all settings to their default values. Your work entries will be preserved.',
          style: TextStyle(color: AppTheme.primaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement reset app
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App settings reset'),
                  backgroundColor: AppTheme.neonYellowGreen,
                ),
              );
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(showBackButton: true),
      ),
    );
  }
}
