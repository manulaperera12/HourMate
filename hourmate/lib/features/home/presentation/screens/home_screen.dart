import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
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
                        HorizontalProgressList(weekProgress: _mockWeekProgress),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(
                              //   color: AppTheme.disabledTextColor,
                              //   width: 2,
                              // ),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius:
                                    1.0, // Adjust radius to control the spread of the gradient
                                colors: [
                                  Color(0xFF2C2C2C), // Dark grey for the center
                                  Color(0xFF1A1A1A).withValues(
                                    alpha: 0.5,
                                  ), // Slightly darker grey for the outer part
                                  Color(0xFF0D0D0D).withValues(
                                    alpha: 0.0,
                                  ), // Even darker, almost black for the edges
                                ],
                                stops: const [
                                  0.0,
                                  0.5,
                                  1.0,
                                ], // Control where each color stops
                              ),
                              color: null, // Remove solid color
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

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bottomNavBg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.bottomNavSelected,
            unselectedItemColor: AppTheme.bottomNavUnselected.withOpacity(0.7),
            selectedFontSize: 13,
            unselectedFontSize: 13,
            iconSize: 28,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'Log',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Summary',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 1:
                  _navigateToWorkLog();
                  break;
                case 2:
                  _navigateToWeeklySummary();
                  break;
                case 3:
                  _navigateToSettings();
                  break;
              }
            },
          ),
        ),
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
    // TODO: Navigate to weekly summary page
  }

  void _navigateToSettings() {
    // TODO: Navigate to settings page
  }
}
