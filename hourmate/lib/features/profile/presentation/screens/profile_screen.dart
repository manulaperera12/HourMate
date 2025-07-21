import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_achievement_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_action_button.dart';
import '../../domain/entities/achievement.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/achievements_cubit.dart';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../home/data/datasources/work_entry_local_datasource.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../main.dart';
import '../widgets/level_up_popup.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AchievementsCubit()..loadAchievements(),
      child: _ProfileScreenContent(showBackButton: showBackButton),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  final bool showBackButton;
  const _ProfileScreenContent({Key? key, required this.showBackButton})
    : super(key: key);

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  // --- Export Data Methods ---
  void _exportData(String format) async {
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
    final excel = xls.Excel.createExcel();
    final workSheet = excel['Work Entries'] as dynamic;
    final workEntries = exportData['workEntries'] as List<dynamic>;
    if (workEntries.isNotEmpty) {
      workSheet.appendRow(
        workEntries.first.keys.map((e) => e.toString()).toList(),
      );
      for (final entry in workEntries) {
        workSheet.appendRow(entry.values.map((e) => e.toString()).toList());
      }
    } else {
      workSheet.appendRow(['No work entries found']);
    }
    final goalsSheet = excel['Goals'] as dynamic;
    final goals = exportData['customGoals'] as List<dynamic>;
    if (goals.isNotEmpty) {
      goalsSheet.appendRow(goals.first.keys.map((e) => e.toString()).toList());
      for (final goal in goals) {
        goalsSheet.appendRow(goal.values.map((e) => e.toString()).toList());
      }
    } else {
      goalsSheet.appendRow(['No goals found']);
    }
    final breaksSheet = excel['Breaks'] as dynamic;
    final breaks = exportData['breaks'] as List<dynamic>;
    if (breaks.isNotEmpty) {
      breaksSheet.appendRow(
        breaks.first.keys.map((e) => e.toString()).toList(),
      );
      for (final brk in breaks) {
        breaksSheet.appendRow(brk.values.map((e) => e.toString()).toList());
      }
    } else {
      breaksSheet.appendRow(['No breaks found']);
    }
    final settingsSheet = excel['Settings'] as dynamic;
    final settings = exportData['settings'] as Map<String, dynamic>;
    settingsSheet.appendRow(['Setting', 'Value']);
    settings.forEach((key, value) {
      settingsSheet.appendRow([key.toString(), value.toString()]);
    });
    final profileSheet = excel['Profile'] as dynamic;
    final profile = exportData['profile'] as Map<String, dynamic>;
    profileSheet.appendRow(['Field', 'Value']);
    profile.forEach((key, value) {
      profileSheet.appendRow([key.toString(), value.toString()]);
    });
    final bytes = excel.encode();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/hourmate_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes!);
    await Share.shareXFiles([XFile(file.path)], text: 'HourMate Data Export');
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataSource = WorkEntryLocalDataSource();
      final entries = (await dataSource.getAllWorkEntries())
          .map((e) => e.toEntity())
          .toList();
      // Only completed entries
      final completed = entries.where((e) => !e.isActive).toList();
      // Total hours
      final totalHours = completed.fold<double>(
        0.0,
        (sum, e) => sum + e.durationInHours,
      );
      // Total sessions
      final totalSessions = completed.length;
      // Average rating (Good=2, Average=1, Bad=0)
      double avgRating = 0.0;
      if (completed.isNotEmpty) {
        final ratingSum = completed.fold<int>(0, (sum, e) {
          switch (e.taskRating) {
            case 'Good':
              return sum + 2;
            case 'Average':
              return sum + 1;
            case 'Bad':
              return sum + 0;
            default:
              return sum;
          }
        });
        avgRating = ratingSum / completed.length;
      }
      // Streak calculation
      final days =
          completed
              .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
              .toSet()
              .toList()
            ..sort();
      int streak = 0;
      int maxStreak = 0;
      DateTime? prev;
      for (final d in days) {
        if (prev == null || d.difference(prev).inDays == 1) {
          streak++;
        } else {
          streak = 1;
        }
        if (streak > maxStreak) maxStreak = streak;
        prev = d;
      }
      // Level calculation based on experience (10 XP per session)
      int experience = totalSessions * 10;
      int level = (experience / 100).floor() + 1;
      int nextLevel = level * 100;
      final prevLevel = prefs.getInt('level') ?? 1;
      if (level > prevLevel) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (globalNavigatorKey.currentState != null) {
            showDialog(
              context: globalNavigatorKey.currentState!.overlay!.context,
              barrierDismissible: false,
              builder: (context) => LevelUpPopup(newLevel: level),
            );
          }
        });
        await prefs.setInt('level', level);
      }
      setState(() {
        _userData = {
          'name': prefs.getString('user_name') ?? 'User',
          'position': prefs.getString('user_position') ?? 'Professional',
          'company': prefs.getString('user_company') ?? '',
          'avatar': prefs.getString('user_avatar') ?? 'U',
          'joinDate': _formatJoinDate(prefs.getString('join_date')),
          'totalHours': totalHours,
          'totalSessions': totalSessions,
          'averageRating': avgRating,
          'streakDays': maxStreak,
          'level': level,
          'experience': experience,
          'nextLevel': nextLevel,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userData = {
          'name': 'User',
          'position': 'Professional',
          'company': '',
          'avatar': 'U',
          'joinDate': 'Recently',
          'totalHours': 0.0,
          'totalSessions': 0,
          'averageRating': 0.0,
          'streakDays': 0,
          'level': 1,
          'experience': 0,
          'nextLevel': 100,
        };
        _isLoading = false;
      });
    }
  }

  String _formatJoinDate(String? dateString) {
    if (dateString == null) return 'Recently';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference < 30) {
        return '${difference} days ago';
      } else if (difference < 365) {
        final months = (difference / 30).floor();
        return '${months} month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference / 365).floor();
        return '${years} year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _showEditProfileSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final nameController = TextEditingController(text: _userData['name']);
    final positionController = TextEditingController(
      text: _userData['position'],
    );
    final companyController = TextEditingController(text: _userData['company']);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppTheme.disabledTextColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonYellowGreen,
                        foregroundColor: AppTheme.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await prefs.setString(
                          'user_name',
                          nameController.text.trim(),
                        );
                        await prefs.setString(
                          'user_position',
                          positionController.text.trim(),
                        );
                        await prefs.setString(
                          'user_company',
                          companyController.text.trim(),
                        );
                        if (mounted) {
                          Navigator.of(context).pop();
                          _loadUserData();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  Icons.person_rounded,
                  color: AppTheme.black,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Profile...',
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
                    title: 'Profile',
                    subtitle: 'Your work journey',
                    showBackButton: widget.showBackButton,
                    leading: Container(
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
                          _userData['avatar'] ?? 'U',
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
                      ProfileInfoCard(userData: _userData),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatsCard(
                              title: 'Total Hours',
                              value:
                                  '${_userData['totalHours'].toStringAsFixed(1)}h',
                              icon: Icons.access_time_rounded,
                              color: AppTheme.neonYellowGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProfileStatsCard(
                              title: 'Sessions',
                              value: '${_userData['totalSessions']}',
                              icon: Icons.work_rounded,
                              color: AppTheme.cyanBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatsCard(
                              title: 'Rating',
                              value: '${_userData['averageRating']}',
                              icon: Icons.star_rounded,
                              color: AppTheme.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProfileStatsCard(
                              title: 'Streak',
                              value: '${_userData['streakDays']}d',
                              icon: Icons.local_fire_department_rounded,
                              color: AppTheme.neonYellowGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyanBlue.withValues(
                                      alpha: 0.13,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    color: AppTheme.cyanBlue,
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
                                        'Level ${_userData['level']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_userData['experience']} / ${_userData['nextLevel']} XP',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
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
                            const SizedBox(height: 16),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.disabledTextColor.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    _userData['experience'] /
                                    _userData['nextLevel'],
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.neonYellowGreen,
                                        AppTheme.cyanBlue,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: BlocBuilder<AchievementsCubit, List<Achievement>>(
                          builder: (context, achievements) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppTheme.orange.withValues(
                                          alpha: 0.13,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.emoji_events_rounded,
                                        color: AppTheme.orange,
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
                                            'Achievements',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${achievements.where((a) => a.unlocked).length}/${achievements.length} unlocked',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...achievements.map(
                                  (achievement) => ProfileAchievementCard(
                                    achievement: {
                                      'title': achievement.title,
                                      'description': achievement.description,
                                      'icon': achievement.icon,
                                      'color': achievement.color,
                                      'unlocked': achievement.unlocked,
                                      'progress': achievement.progress,
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProfileActionButton(
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        icon: Icons.edit_rounded,
                        color: AppTheme.neonYellowGreen,
                        onTap: _showEditProfileSheet,
                      ),
                      const SizedBox(height: 12),
                      ProfileActionButton(
                        title: 'Export Data',
                        subtitle: 'Download your work history',
                        icon: Icons.download_rounded,
                        color: AppTheme.cyanBlue,
                        onTap: () {
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
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
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
                                              color: AppTheme.disabledTextColor
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
                                              foregroundColor: AppTheme.black,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                      ProfileActionButton(
                        title: 'Share Profile',
                        subtitle: 'Share your achievements',
                        icon: Icons.share_rounded,
                        color: AppTheme.orange,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final name = prefs.getString('user_name') ?? 'User';
                          final level = _userData['level'] ?? 1;
                          final totalHours = _userData['totalHours'] ?? 0;
                          final totalSessions = _userData['totalSessions'] ?? 0;
                          final streak = _userData['streakDays'] ?? 0;
                          final achievements = [
                            if (prefs.getBool('achievement_early_bird_shown') ??
                                false)
                              '🌅 Early Bird',
                            if (prefs.getBool(
                                  'achievement_consistency_king_shown',
                                ) ??
                                false)
                              '👑 Consistency King',
                            if (prefs.getBool(
                                  'achievement_task_crusher_shown',
                                ) ??
                                false)
                              '💪 Task Crusher',
                            if (prefs.getBool(
                                  'achievement_focus_master_shown',
                                ) ??
                                false)
                              '🎯 Focus Master',
                          ];
                          final shareText =
                              '''Check out my HourMate profile!\n\n'
Name: $name\nLevel: $level\nTotal Hours: $totalHours\nSessions: $totalSessions\nStreak: $streak days\n\nAchievements:\n${achievements.isNotEmpty ? achievements.join(", ") : "No achievements yet"}\n\nJoin me on HourMate!''';
                          await Share.share(
                            shareText,
                            subject: 'My HourMate Profile',
                          );
                        },
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
}
