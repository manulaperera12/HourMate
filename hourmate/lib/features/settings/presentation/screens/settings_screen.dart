import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/services/settings_service.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_slider_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/blocs/work_tracking_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../home/data/datasources/work_entry_local_datasource.dart';
import '../../../home/data/models/work_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncfusion;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../onboarding/presentation/screens/get_started_screen.dart';
import '../../../home/domain/usecases/get_work_entries_usecase.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../main.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBackButton;
  final GetWorkEntriesUseCase getWorkEntriesUseCase;

  const SettingsScreen({
    super.key,
    this.showBackButton = false,
    required this.getWorkEntriesUseCase,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoClockOutEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _workGoalHours = 8.0;
  double _breakReminderMinutes = 60.0;
  String _workStartTime = '09:00';
  String _workEndTime = '17:00';
  double _weeklyGoal = 40.0;
  bool _useSevenDays = false;
  String _breakEndSound = 'chime.mp3';
  final List<Map<String, String>> _soundOptions = [
    {'file': 'chime.mp3', 'label': 'Chime'},
    {'file': 'bell.mp3', 'label': 'Bell'},
    {'file': 'beep.mp3', 'label': 'Beep'},
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBreakEndSound();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsService.getAllSettings();
      final weeklyGoalDays = await SettingsService.getWeeklyGoalDays();
      setState(() {
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
        _soundEnabled = settings['soundEnabled'] ?? true;
        _vibrationEnabled = settings['vibrationEnabled'] ?? true;
        _autoClockOutEnabled = settings['autoClockOutEnabled'] ?? false;
        _workGoalHours = settings['dailyGoal'] ?? 8.0;
        _breakReminderMinutes = settings['breakDuration']?.toDouble() ?? 60.0;
        _workStartTime = settings['workStartTime'] ?? '09:00';
        _workEndTime = settings['workEndTime'] ?? '17:00';
        _weeklyGoal = settings['weeklyGoal'] ?? 40.0;
        _useSevenDays = weeklyGoalDays == 7;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBreakEndSound() async {
    final sound = await SettingsService.getBreakEndSound();
    setState(() {
      _breakEndSound = sound;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.cyanBlue, AppTheme.neonYellowGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonYellowGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppTheme.black,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Settings...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: AppHeader(
                    title: 'Settings',
                    subtitle: 'Customize your HourMate experience',
                    showBackButton: widget.showBackButton,
                    onAvatarTap: _navigateToProfile,
                  ),
                ),
                expandedHeight: 105,
                toolbarHeight: 105,
              ),
              SliverToBoxAdapter(
                child: Padding(
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 1.0,
                                  colors: [
                                    const Color(0xFF2C2C2C),
                                    const Color(
                                      0xFF1A1A1A,
                                    ).withValues(alpha: 0.5),
                                    const Color(
                                      0xFF0D0D0D,
                                    ).withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly goal based on:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.primaryTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text(
                                          '5 days',
                                          style: TextStyle(
                                            color: !_useSevenDays
                                                ? Colors.black
                                                : AppTheme.disabledTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        checkmarkColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          side: BorderSide(
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                        selected: !_useSevenDays,
                                        selectedColor: AppTheme.neonYellowGreen,
                                        backgroundColor: AppTheme.cardColor,
                                        onSelected: (selected) async {
                                          if (selected) {
                                            setState(
                                              () => _useSevenDays = false,
                                            );
                                            final bloc = context
                                                .read<WorkTrackingBloc>();
                                            await SettingsService.setWeeklyGoalDays(
                                              5,
                                            );
                                            if (mounted) {
                                              bloc.add(LoadWorkEntries());
                                            }
                                            await _loadSettings();
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      ChoiceChip(
                                        label: Text(
                                          '7 days',
                                          style: TextStyle(
                                            color: _useSevenDays
                                                ? Colors.black
                                                : AppTheme.disabledTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        checkmarkColor: Colors.black,
                                        selected: _useSevenDays,
                                        selectedColor: AppTheme.neonYellowGreen,
                                        backgroundColor: AppTheme.cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          side: BorderSide(
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                        onSelected: (selected) async {
                                          if (selected) {
                                            setState(
                                              () => _useSevenDays = true,
                                            );
                                            final bloc = context
                                                .read<WorkTrackingBloc>();
                                            await SettingsService.setWeeklyGoalDays(
                                              7,
                                            );
                                            if (mounted) {
                                              bloc.add(LoadWorkEntries());
                                            }
                                            await _loadSettings();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SettingsSliderTile(
                            title: 'Daily Work Goal',
                            subtitle:
                                '${_workGoalHours.toStringAsFixed(1)} hours',
                            value: _workGoalHours,
                            min: 1.0,
                            max: 12.0,
                            divisions: 22,
                            onChanged: (value) async {
                              setState(() {
                                _workGoalHours = value;
                              });
                              await SettingsService.setDailyGoal(value);
                              if (mounted) {
                                context.read<WorkTrackingBloc>().add(
                                  LoadWorkEntries(),
                                );
                              }
                              await _loadSettings();
                            },
                          ),
                          SettingsSwitchTile(
                            title: 'Auto Clock Out',
                            subtitle: 'Automatically clock out after 8 hours',
                            value: _autoClockOutEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _autoClockOutEnabled = value;
                              });
                              await SettingsService.setAutoClockOutEnabled(
                                value,
                              );
                            },
                          ),
                          // Break Duration Slider
                          SettingsSliderTile(
                            title: 'Default Break Duration',
                            subtitle:
                                'How long should your breaks be? (minutes)',
                            value: _breakReminderMinutes.clamp(5, 30),
                            min: 5,
                            max: 30,
                            divisions: 5,
                            onChanged: (value) async {
                              setState(() {
                                _breakReminderMinutes = value;
                              });
                              await SettingsService.setBreakDuration(
                                value.toInt(),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Notifications
                      SettingsSection(
                        title: 'Feedback & Alerts',
                        icon: Icons.feedback_rounded,
                        color: AppTheme.cyanBlue,
                        children: [
                          SettingsSwitchTile(
                            title: 'Sound',
                            subtitle: 'Play notification sounds',
                            value: _soundEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _soundEnabled = value;
                              });
                              await SettingsService.setSoundEnabled(value);
                            },
                          ),
                          SettingsSwitchTile(
                            title: 'Vibration',
                            subtitle: 'Vibrate on notifications',
                            value: _vibrationEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _vibrationEnabled = value;
                              });
                              await SettingsService.setVibrationEnabled(value);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Data & Privacy
                      SettingsSection(
                        title: 'Data',
                        icon: Icons.security_rounded,
                        color: AppTheme.neonYellowGreen,
                        children: [
                          SettingsTile(
                            title: 'Export Data',
                            subtitle: 'Download your work logs',
                            icon: Icons.download_rounded,
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                    initialChildSize: 0.35,
                                    minChildSize: 0.2,
                                    maxChildSize: 0.7,
                                    expand: false,
                                    builder: (context, scrollController) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(28),
                                              ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 24,
                                              offset: const Offset(0, -8),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.only(
                                          left: 24,
                                          right: 24,
                                          top: 24,
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom +
                                              24,
                                        ),
                                        child: ListView(
                                          controller: scrollController,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 48,
                                                height: 5,
                                                margin: const EdgeInsets.only(
                                                  bottom: 18,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme
                                                      .disabledTextColor
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Export Data',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Download all your work entries, goals, breaks, settings, and profile as an Excel file.',
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.download_rounded,
                                                ),
                                                label: const Text(
                                                  'Download as Excel',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.cyanBlue,
                                                  foregroundColor:
                                                      AppTheme.black,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  _exportData('excel');
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Break End Sound
                      SettingsSection(
                        title: 'Break End Sound',
                        icon: Icons.music_note_rounded,
                        color: AppTheme.cyanBlue,
                        children: [
                          ..._soundOptions.map(
                            (option) => ListTile(
                              leading: Radio<String>(
                                value: option['file']!,
                                groupValue: _breakEndSound,
                                onChanged: (value) async {
                                  setState(() {
                                    _breakEndSound = value!;
                                  });
                                  await SettingsService.setBreakEndSound(
                                    value!,
                                  );
                                },
                                activeColor: AppTheme.cyanBlue,
                              ),
                              title: Text(
                                option['label']!,
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppTheme.cyanBlue,
                                ),
                                onPressed: () async {
                                  await _audioPlayer.stop();
                                  await _audioPlayer.play(
                                    AssetSource('sounds/${option['file']}'),
                                  );
                                },
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: AppTheme.surfaceColor.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
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
          'This will permanently delete all your work entries and work-related settings. Your profile setup will be preserved.',
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
            onPressed: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              // Remove work-related keys only
              await prefs.remove('work_entries');
              await prefs.remove('custom_goals');
              await prefs.remove('breaks');
              await prefs.remove('break_duration');
              await prefs.remove('auto_clock_out');
              await prefs.remove('auto_clock_out_duration');
              await prefs.remove('weekly_goal');
              await prefs.remove('daily_goal');
              await prefs.remove('weekly_goal_days');
              await prefs.remove('break_end_sound');
              // Clear all work entries from local data source
              final dataSource = WorkEntryLocalDataSource();
              await dataSource.clearAll();
              await _loadSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All work data cleared'),
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
          'This will reset all settings and profile to their default values and remove all data. The app will restart from the get started screen.',
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
            onPressed: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              final dataSource = WorkEntryLocalDataSource();
              await dataSource.clearAll();
              await _loadSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App reset. Please restart the app.'),
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

  void _exportData(String format) async {
    // 1. Aggregate all user data
    final workEntries = await _getAllWorkEntries();
    final customGoals = await SettingsService.getCustomGoals();
    final breaks = await SettingsService.getAllBreaksRaw();
    final settings = await SettingsService.getAllSettings();
    final profile = await _getProfileData();

    final exportData = {
      'workEntries': workEntries,
      'customGoals': customGoals,
      'breaks': breaks,
      'settings': settings,
      'profile': profile,
    };

    // 2. Generate file
    if (format == 'excel') {
      await _exportToExcel(exportData);
    }
  }

  Future<List<Map<String, dynamic>>> _getAllWorkEntries() async {
    final dataSource = WorkEntryLocalDataSource();
    final entries = await dataSource.getAllWorkEntries();
    return entries.map((e) => e.toMap()).toList();
  }

  Future<Map<String, dynamic>> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'User',
      'position': prefs.getString('user_position') ?? 'Professional',
      'company': prefs.getString('user_company') ?? '',
      'avatar': prefs.getString('user_avatar') ?? 'U',
      'joinDate': prefs.getString('join_date'),
      'totalHours': prefs.getDouble('total_hours') ?? 0.0,
      'totalSessions': prefs.getInt('total_sessions') ?? 0,
      'averageRating': prefs.getDouble('average_rating') ?? 0.0,
      'streakDays': prefs.getInt('streak_days') ?? 0,
      'level': prefs.getInt('level') ?? 1,
      'experience': prefs.getInt('experience') ?? 0,
      'nextLevel': prefs.getInt('next_level') ?? 100,
    };
  }

  Future<void> _exportToExcel(Map<String, dynamic> exportData) async {
    final workbook = syncfusion.Workbook();
    // Work Entries
    final workSheet = workbook.worksheets[0];
    workSheet.name = 'Work Entries';
    final workEntries = exportData['workEntries'] as List<dynamic>;
    int row = 1;
    if (workEntries.isNotEmpty) {
      final headers = workEntries.first.keys.toList();
      for (int i = 0; i < headers.length; i++) {
        workSheet.getRangeByIndex(row, i + 1).setText(headers[i].toString());
      }
      row++;
      for (final entry in workEntries) {
        final values = entry.values.toList();
        for (int i = 0; i < values.length; i++) {
          workSheet.getRangeByIndex(row, i + 1).setText(values[i].toString());
        }
        row++;
      }
    } else {
      workSheet.getRangeByIndex(row, 1).setText('No work entries found');
    }
    // Goals
    final goalsSheet = workbook.worksheets.addWithName('Goals');
    final goals = exportData['customGoals'] as List<dynamic>;
    row = 1;
    if (goals.isNotEmpty) {
      final headers = goals.first.keys.toList();
      for (int i = 0; i < headers.length; i++) {
        goalsSheet.getRangeByIndex(row, i + 1).setText(headers[i].toString());
      }
      row++;
      for (final goal in goals) {
        final values = goal.values.toList();
        for (int i = 0; i < values.length; i++) {
          goalsSheet.getRangeByIndex(row, i + 1).setText(values[i].toString());
        }
        row++;
      }
    } else {
      goalsSheet.getRangeByIndex(row, 1).setText('No goals found');
    }
    // Breaks
    final breaksSheet = workbook.worksheets.addWithName('Breaks');
    final breaks = exportData['breaks'] as List<dynamic>;
    row = 1;
    if (breaks.isNotEmpty) {
      final headers = breaks.first.keys.toList();
      for (int i = 0; i < headers.length; i++) {
        breaksSheet.getRangeByIndex(row, i + 1).setText(headers[i].toString());
      }
      row++;
      for (final brk in breaks) {
        final values = brk.values.toList();
        for (int i = 0; i < values.length; i++) {
          breaksSheet.getRangeByIndex(row, i + 1).setText(values[i].toString());
        }
        row++;
      }
    } else {
      breaksSheet.getRangeByIndex(row, 1).setText('No breaks found');
    }
    // Settings
    final settingsSheet = workbook.worksheets.addWithName('Settings');
    final settings = exportData['settings'] as Map<String, dynamic>;
    settingsSheet.getRangeByIndex(1, 1).setText('Setting');
    settingsSheet.getRangeByIndex(1, 2).setText('Value');
    row = 2;
    settings.forEach((key, value) {
      settingsSheet.getRangeByIndex(row, 1).setText(key.toString());
      settingsSheet.getRangeByIndex(row, 2).setText(value.toString());
      row++;
    });
    // Profile
    final profileSheet = workbook.worksheets.addWithName('Profile');
    profileSheet.getRangeByIndex(1, 1).setText('Field');
    profileSheet.getRangeByIndex(1, 2).setText('Value');
    row = 2;
    final profile = exportData['profile'] as Map<String, dynamic>;
    profile.forEach((key, value) {
      profileSheet.getRangeByIndex(row, 1).setText(key.toString());
      profileSheet.getRangeByIndex(row, 2).setText(value.toString());
      row++;
    });
    // Save file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/hourmate_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes, flush: true);
    // Share file
    await Share.shareXFiles([XFile(file.path)], text: 'HourMate Data Export');
  }
}
