import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../weekly_summary/presentation/screens/summary_screen.dart';
import '../blocs/work_tracking_bloc.dart';
import '../widgets/clock_in_out_button.dart';
import '../widgets/work_status_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/clock_in_modal.dart';
import '../widgets/clock_out_modal.dart';
import '../widgets/home_header.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/horizontal_progress_list.dart';
import '../widgets/today_progress_circle.dart';
import '../widgets/stats_row.dart';
import '../../../work_log/presentation/screens/work_log_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showBackButton;
  const HomeScreen({super.key, this.showBackButton = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  // Mock week progress data
  final List<DayProgress> _mockWeekProgress = [
    DayProgress(percent: 0.36, dayLabel: 'Mon', dateLabel: '02'),
    DayProgress(percent: 0.60, dayLabel: 'Tue', dateLabel: '03'),
    DayProgress(percent: 0.45, dayLabel: 'Wed', dateLabel: '04'),
    DayProgress(percent: 0.75, dayLabel: 'Thu', dateLabel: '05'),
    DayProgress(percent: 0.0, dayLabel: 'Fri', dateLabel: '06'),
    DayProgress(percent: 0.0, dayLabel: 'Sat', dateLabel: '07'),
    DayProgress(percent: 0.0, dayLabel: 'Sun', dateLabel: '08'),
  ];

  @override
  void initState() {
    super.initState();
    // Load work entries when the page initializes
    context.read<WorkTrackingBloc>().add(LoadWorkEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove backgroundColor from Scaffold to allow gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // AppTheme.headerGradientStart, // Neon yellow-green
              AppTheme.headerGradientStart.withValues(alpha: 0.8),
              AppTheme.backgroundColor, // Dark/black
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.5, 0.9, 1.0], // Top 30% is neon, then fades to dark
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<WorkTrackingBloc, WorkTrackingState>(
            listener: (context, state) {
              if (state is WorkTrackingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is WorkTrackingLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              if (state is WorkTrackingLoaded) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeHeader(
                          dateRange: 'Jul 15-21',
                          onSettingsTap: _navigateToSettings,
                          onAvatarTap: _navigateToProfile,
                          showBackButton: widget.showBackButton,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HomeTabBar(
                            selectedIndex: _selectedTab,
                            onTabSelected: (index) {
                              setState(() => _selectedTab = index);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildTabContent(_selectedTab, state),
                        ),
                        const SizedBox(height: 20),
                        // Clock In/Out Button
                        ClockInOutButton(
                          isClockInEnabled: state.isClockInEnabled,
                          activeWorkEntry: state.activeWorkEntry,
                          onClockIn: _showClockInModal,
                          onClockOut: _showClockOutModal,
                        ),
                        // Work Status Card
                        if (state.activeWorkEntry != null)
                          WorkStatusCard(workEntry: state.activeWorkEntry!),
                        // Quick Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          child: QuickActions(
                            onViewLog: () => _navigateToWorkLog(),
                            onViewSummary: () => _navigateToWeeklySummary(),
                          ),
                        ),
                        // Today's Work Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: _buildTodaySummary(state.workEntries),
                        ),
                        const SizedBox(
                          height: 100,
                        ), // Bottom padding for navigation
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('Something went wrong'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummary(List<dynamic> workEntries) {
    final DateTime today = DateTime.now();
    final List<dynamic> todayEntries = workEntries.where((entry) {
      return entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day;
    }).toList();

    double totalHours = 0.0;
    for (final entry in todayEntries) {
      if (!entry.isActive) {
        totalHours += entry.durationInHours;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Work',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${totalHours.toStringAsFixed(1)} hours',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${todayEntries.length} sessions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int index, WorkTrackingState state) {
    switch (index) {
      case 0: // Today
        return Container(
          key: const ValueKey('today'),
          child: Column(
            children: [
              HorizontalProgressList(weekProgress: _mockWeekProgress),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TodayProgressCircle(
                        worked: const Duration(hours: 6, minutes: 10),
                        goal: const Duration(hours: 8),
                      ),
                      const SizedBox(height: 20),
                      StatsRow(
                        hoursWorked: '6:10',
                        tasksDone: 5,
                        productivityScore: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1: // Plans
        return Container(
          key: const ValueKey('plans'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Plans Header
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
                              color: AppTheme.cyanBlue.withValues(alpha: 0.13),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: AppTheme.cyanBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This Week\'s Plan',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTextColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your weekly goals',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Weekly Goals
                      _buildGoalItem(
                        'Complete Project A',
                        0.7,
                        AppTheme.neonYellowGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildGoalItem('Code Review', 0.9, AppTheme.cyanBlue),
                      const SizedBox(height: 12),
                      _buildGoalItem('Documentation', 0.4, AppTheme.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 2: // Daily
        return Container(
          key: const ValueKey('daily'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Daily Stats Header
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
                              color: AppTheme.orange.withValues(alpha: 0.13),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              color: AppTheme.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Insights',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTextColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your productivity patterns',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Daily Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildDailyStat(
                              'Peak Hours',
                              '9 AM - 11 AM',
                              Icons.access_time_rounded,
                              AppTheme.neonYellowGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDailyStat(
                              'Focus Score',
                              '85%',
                              Icons.psychology_rounded,
                              AppTheme.cyanBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDailyStat(
                              'Breaks Taken',
                              '3',
                              Icons.coffee_rounded,
                              AppTheme.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDailyStat(
                              'Tasks Done',
                              '8/10',
                              Icons.check_circle_rounded,
                              AppTheme.neonYellowGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGoalItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.disabledTextColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClockInModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ClockInModal(),
    );
  }

  void _showClockOutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ClockOutModal(),
    );
  }

  void _navigateToWorkLog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkLogScreen(showBackButton: true),
      ),
    );
  }

  void _navigateToWeeklySummary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SummaryScreen(showBackButton: true),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(showBackButton: true),
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
