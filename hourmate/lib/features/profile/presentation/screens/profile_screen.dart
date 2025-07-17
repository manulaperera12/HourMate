import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_achievement_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_action_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _userData = {
          'name': prefs.getString('user_name') ?? 'User',
          'email': prefs.getString('user_email') ?? 'user@email.com',
          'position': prefs.getString('user_position') ?? 'Professional',
          'company': prefs.getString('user_company') ?? 'Company',
          'avatar': prefs.getString('user_avatar') ?? 'U',
          'joinDate': _formatJoinDate(prefs.getString('join_date')),
          'totalHours': prefs.getDouble('total_hours') ?? 0.0,
          'totalSessions': prefs.getInt('total_sessions') ?? 0,
          'averageRating': prefs.getDouble('average_rating') ?? 0.0,
          'streakDays': prefs.getInt('streak_days') ?? 0,
          'level': prefs.getInt('level') ?? 1,
          'experience': prefs.getInt('experience') ?? 0,
          'nextLevel': prefs.getInt('next_level') ?? 100,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userData = {
          'name': 'User',
          'email': 'user@email.com',
          'position': 'Professional',
          'company': 'Company',
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

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Early Bird',
      'description': 'Start work before 8 AM for 7 days',
      'icon': Icons.wb_sunny_rounded,
      'color': AppTheme.neonYellowGreen,
      'unlocked': true,
      'progress': 1.0,
    },
    {
      'title': 'Focus Master',
      'description': 'Complete 50 tasks with 90%+ productivity',
      'icon': Icons.psychology_rounded,
      'color': AppTheme.cyanBlue,
      'unlocked': true,
      'progress': 1.0,
    },
    {
      'title': 'Consistency King',
      'description': 'Work 30 consecutive days',
      'icon': Icons.local_fire_department_rounded,
      'color': AppTheme.orange,
      'unlocked': false,
      'progress': 0.93,
    },
    {
      'title': 'Task Crusher',
      'description': 'Complete 100 tasks in a month',
      'icon': Icons.check_circle_rounded,
      'color': AppTheme.neonYellowGreen,
      'unlocked': false,
      'progress': 0.67,
    },
  ];

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
          child: Column(
            children: [
              // Header
              AppHeader(
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
              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Info Card
                      ProfileInfoCard(userData: _userData),

                      const SizedBox(height: 24),

                      // Stats Cards
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

                      // Level Progress
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

                      // Achievements Section
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
                                              color: AppTheme.primaryTextColor,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_achievements.where((a) => a['unlocked']).length}/${_achievements.length} unlocked',
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
                            const SizedBox(height: 20),
                            ..._achievements.map(
                              (achievement) => ProfileAchievementCard(
                                achievement: achievement,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      ProfileActionButton(
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        icon: Icons.edit_rounded,
                        color: AppTheme.neonYellowGreen,
                        onTap: () {
                          // TODO: Navigate to edit profile
                        },
                      ),

                      const SizedBox(height: 12),

                      ProfileActionButton(
                        title: 'Export Data',
                        subtitle: 'Download your work history',
                        icon: Icons.download_rounded,
                        color: AppTheme.cyanBlue,
                        onTap: () {
                          // TODO: Export data functionality
                        },
                      ),

                      const SizedBox(height: 12),

                      ProfileActionButton(
                        title: 'Share Profile',
                        subtitle: 'Share your achievements',
                        icon: Icons.share_rounded,
                        color: AppTheme.orange,
                        onTap: () {
                          // TODO: Share profile functionality
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
