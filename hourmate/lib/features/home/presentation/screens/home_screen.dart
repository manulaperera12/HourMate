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
import '../../../home/domain/usecases/get_work_entries_usecase.dart';
import 'package:intl/intl.dart';
import '../../../home/domain/entities/work_entry.dart';
import '../../../../core/services/settings_service.dart';
import '../widgets/break_timer_card.dart';

class HomeScreen extends StatefulWidget {
  final bool showBackButton;
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  const HomeScreen({
    super.key,
    this.showBackButton = false,
    required this.getWorkEntriesUseCase,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> _customGoals = [];
  int _breakDuration = 15; // default, will be loaded from settings

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

  String get _currentWeekRange {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startMonth = DateFormat('MMM').format(startOfWeek);
    final endMonth = DateFormat('MMM').format(endOfWeek);
    final startDay = DateFormat('d').format(startOfWeek);
    final endDay = DateFormat('d').format(endOfWeek);
    if (startMonth == endMonth) {
      return '$startMonth $startDay-$endDay';
    } else {
      return '$startMonth $startDay - $endMonth $endDay';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomGoals();
    _loadBreakDuration();
    context.read<WorkTrackingBloc>().add(LoadWorkEntries());
    context.read<WorkTrackingBloc>().add(RestoreBreak());
  }

  Future<void> _loadCustomGoals() async {
    final goals = await SettingsService.getCustomGoals();
    setState(() {
      _customGoals = goals;
    });
  }

  Future<void> _loadBreakDuration() async {
    final duration = await SettingsService.getBreakDuration();
    setState(() {
      _breakDuration = duration;
    });
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(
                      dateRange: _currentWeekRange,
                      onSettingsTap: _navigateToSettings,
                      onAvatarTap: _navigateToProfile,
                      showBackButton: widget.showBackButton,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                WorkStatusCard(
                                  workEntry: state.activeWorkEntry!,
                                ),
                              // Quick Actions
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: QuickActions(
                                  onViewLog: () => _navigateToWorkLog(),
                                  onViewSummary: () =>
                                      _navigateToWeeklySummary(),
                                ),
                              ),
                              // Break Timer Card
                              BreakTimerCard(
                                isOnBreak: state.isOnBreak,
                                breakDurationMinutes:
                                    state.breakDurationMinutes,
                                breakElapsedSeconds: state.breakElapsedSeconds,
                                breakRemainingSeconds:
                                    state.breakRemainingSeconds,
                                defaultDuration:
                                    state.breakDurationMinutes ??
                                    _breakDuration,
                                onDurationChanged: (v) {
                                  setState(() {
                                    _breakDuration = v;
                                  });
                                },
                                onStartBreak: () {
                                  context.read<WorkTrackingBloc>().add(
                                    StartBreak(durationMinutes: _breakDuration),
                                  );
                                },
                                onEndBreak: () async {
                                  context.read<WorkTrackingBloc>().add(
                                    const EndBreak(),
                                  );
                                  final duration =
                                      await SettingsService.getBreakDuration();
                                  setState(() {
                                    _breakDuration = duration;
                                  });
                                },
                              ),
                              // Today's Work Summary
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: _buildTodaySummary(state.workEntries),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
        List<DayProgress> weekProgress = _mockWeekProgress;
        Duration workedDuration = Duration.zero;
        Duration goalDuration = const Duration(hours: 8);
        if (state is WorkTrackingLoaded) {
          final now = DateTime.now();
          final weekDay = now.weekday;
          final startOfWeek = now.subtract(Duration(days: weekDay - 1));
          final dailyGoal = state.dailyGoal;
          weekProgress = List.generate(7, (i) {
            final date = startOfWeek.add(Duration(days: i));
            final hours = state.workEntries
                .where(
                  (entry) =>
                      entry.date.year == date.year &&
                      entry.date.month == date.month &&
                      entry.date.day == date.day &&
                      !entry.isActive,
                )
                .fold<double>(0.0, (sum, entry) => sum + entry.durationInHours);
            final percent = (dailyGoal > 0 ? (hours / dailyGoal) : 0.0).clamp(
              0.0,
              1.0,
            );
            final dayLabel = DateFormat('E').format(date); // Mon, Tue, etc.
            final dateLabel = DateFormat('d').format(date); // 02, 03, etc.
            return DayProgress(
              percent: percent,
              dayLabel: dayLabel,
              dateLabel: dateLabel,
            );
          });
          final DateTime today = DateTime.now();
          final todayEntries = state.workEntries
              .where(
                (entry) =>
                    entry.date.year == today.year &&
                    entry.date.month == today.month &&
                    entry.date.day == today.day &&
                    !entry.isActive,
              )
              .toList();
          workedDuration = Duration(
            minutes: todayEntries.fold<int>(
              0,
              (sum, entry) => sum + entry.durationInMinutes,
            ),
          );
          goalDuration = Duration(hours: state.dailyGoal.round());
        }
        return Container(
          key: const ValueKey('today'),
          child: Builder(
            builder: (context) {
              // Calculate today's stats
              final DateTime today = DateTime.now();
              final List<WorkEntry> todayEntries = (state is WorkTrackingLoaded)
                  ? state.workEntries
                        .where(
                          (entry) =>
                              entry.date.year == today.year &&
                              entry.date.month == today.month &&
                              entry.date.day == today.day &&
                              !entry.isActive,
                        )
                        .toList()
                  : <WorkEntry>[];
              final workedDuration = Duration(
                minutes: todayEntries.fold<int>(
                  0,
                  (sum, entry) => sum + entry.durationInMinutes,
                ),
              );
              final goalDuration = (state is WorkTrackingLoaded)
                  ? Duration(hours: state.dailyGoal.round())
                  : const Duration(hours: 8);
              final hoursWorkedStr = workedDuration.inHours > 0
                  ? '${workedDuration.inHours}:${(workedDuration.inMinutes % 60).toString().padLeft(2, '0')}'
                  : '${workedDuration.inMinutes} min';
              final tasksDone = todayEntries.length;
              int productivityScore = 0;
              if (todayEntries.isNotEmpty) {
                final scores = todayEntries.map((e) {
                  switch (e.taskRating.toLowerCase()) {
                    case 'good':
                      return 100;
                    case 'average':
                      return 70;
                    case 'bad':
                      return 40;
                    default:
                      return 70;
                  }
                }).toList();
                productivityScore =
                    (scores.reduce((a, b) => a + b) / scores.length).round();
              } else {
                productivityScore = 70;
              }
              return Column(
                children: [
                  HorizontalProgressList(weekProgress: weekProgress),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TodayProgressCircle(
                          worked: workedDuration,
                          goal: goalDuration,
                        ),
                        const SizedBox(height: 20),
                        StatsRow(
                          hoursWorked: hoursWorkedStr,
                          tasksDone: tasksDone,
                          productivityScore: productivityScore,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      case 1: // Plans
        final TextEditingController _goalController = TextEditingController();
        return FutureBuilder<double>(
          future: SettingsService.getWeeklyGoal(),
          builder: (context, snapshot) {
            final weeklyGoal = snapshot.data ?? 40.0;
            double weekHours = 0.0;
            if (state is WorkTrackingLoaded) {
              final now = DateTime.now();
              final weekDay = now.weekday;
              final startOfWeek = now.subtract(Duration(days: weekDay - 1));
              weekHours = 0.0;
              for (int i = 0; i < 7; i++) {
                final date = startOfWeek.add(Duration(days: i));
                final hours = state.workEntries
                    .where(
                      (entry) =>
                          entry.date.year == date.year &&
                          entry.date.month == date.month &&
                          entry.date.day == date.day &&
                          !entry.isActive,
                    )
                    .fold<double>(
                      0.0,
                      (sum, entry) => sum + entry.durationInHours,
                    );
                weekHours += hours;
              }
            }
            final weekPercent = (weekHours / weeklyGoal).clamp(0.0, 1.0);
            return Container(
              key: const ValueKey('plans'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Weekly Goal Progress
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.tabBarBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Hours Goal',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: weekPercent,
                              minHeight: 10,
                              backgroundColor: AppTheme.disabledTextColor
                                  .withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.neonYellowGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weekHours.toStringAsFixed(1)} / ${weeklyGoal.toStringAsFixed(1)} hours',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Custom Goals/Tasks
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.tabBarBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Goals & Tasks',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _goalController,
                                    decoration: InputDecoration(
                                      hintText: 'Add a new goal/task',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppTheme.neonYellowGreen,
                                  ),
                                  onPressed: () async {
                                    final text = _goalController.text.trim();
                                    if (text.isNotEmpty) {
                                      await SettingsService.addCustomGoal(text);
                                      _goalController.clear();
                                      await _loadCustomGoals();
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_customGoals.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'No custom goals yet. Add some above!',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.secondaryTextColor,
                                    ),
                              ),
                            )
                          else
                            ..._customGoals.asMap().entries.map((entry) {
                              final i = entry.key;
                              final goal = entry.value;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: goal['completed'] == true
                                      ? AppTheme.neonYellowGreen.withOpacity(
                                          0.10,
                                        )
                                      : AppTheme.surfaceColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        goal['completed'] == true
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: goal['completed'] == true
                                            ? AppTheme.neonYellowGreen
                                            : AppTheme.disabledTextColor,
                                      ),
                                      onPressed: () async {
                                        await SettingsService.updateCustomGoal(
                                          i,
                                          completed:
                                              !(goal['completed'] == true),
                                        );
                                        await _loadCustomGoals();
                                        setState(() {});
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        goal['title'] ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              decoration:
                                                  goal['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: AppTheme.primaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppTheme.errorColor,
                                      ),
                                      onPressed: () async {
                                        await SettingsService.removeCustomGoal(
                                          i,
                                        );
                                        await _loadCustomGoals();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      case 2: // Daily
        return Container(
          key: const ValueKey('daily'),
          child: Builder(
            builder: (context) {
              final DateTime today = DateTime.now();
              final List<WorkEntry> todayEntries = (state is WorkTrackingLoaded)
                  ? state.workEntries
                        .where(
                          (entry) =>
                              entry.date.year == today.year &&
                              entry.date.month == today.month &&
                              entry.date.day == today.day &&
                              !entry.isActive,
                        )
                        .toList()
                  : <WorkEntry>[];
              // Peak Hours: group by hour, sum minutes, find max
              Map<int, int> hourMinutes = {};
              for (final entry in todayEntries) {
                if (entry.endTime != null) {
                  int startHour = entry.startTime.hour;
                  int endHour = entry.endTime!.hour;
                  for (int h = startHour; h <= endHour; h++) {
                    final start = (h == startHour)
                        ? entry.startTime
                        : DateTime(
                            entry.startTime.year,
                            entry.startTime.month,
                            entry.startTime.day,
                            h,
                          );
                    final end = (h == endHour)
                        ? entry.endTime!
                        : DateTime(
                            entry.startTime.year,
                            entry.startTime.month,
                            entry.startTime.day,
                            h + 1,
                          );
                    final minutes = end
                        .difference(start)
                        .inMinutes
                        .clamp(0, 60);
                    hourMinutes[h] = (hourMinutes[h] ?? 0) + minutes;
                  }
                }
              }
              int peakHour = hourMinutes.isNotEmpty
                  ? (hourMinutes.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                        .first
                        .key
                  : -1;
              int peakMinutes = hourMinutes[peakHour] ?? 0;
              String peakHourLabel = peakHour >= 0
                  ? '${peakHour.toString().padLeft(2, '0')}:00 - ${(peakHour + 1).toString().padLeft(2, '0')}:00'
                  : 'N/A';
              // Focus Score: same as StatsRow
              int productivityScore = 0;
              if (todayEntries.isNotEmpty) {
                final scores = todayEntries.map((e) {
                  switch (e.taskRating.toLowerCase()) {
                    case 'good':
                      return 100;
                    case 'average':
                      return 70;
                    case 'bad':
                      return 40;
                    default:
                      return 70;
                  }
                }).toList();
                productivityScore =
                    (scores.reduce((a, b) => a + b) / scores.length).round();
              } else {
                productivityScore = 70;
              }
              final tasksDone = todayEntries.length;
              return Padding(
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
                                  color: AppTheme.orange.withValues(
                                    alpha: 0.13,
                                  ),
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
                                      'Your productivity patterns',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
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
                                  peakHourLabel,
                                  Icons.access_time_rounded,
                                  AppTheme.neonYellowGreen,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDailyStat(
                                  'Focus Score',
                                  '$productivityScore%',
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
                                child:
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: SettingsService.getBreaksForDate(
                                        today,
                                      ),
                                      builder: (context, snapshot) {
                                        final breaksToday =
                                            snapshot.data
                                                ?.where(
                                                  (b) => b['endTime'] != null,
                                                )
                                                .length ??
                                            0;
                                        return _buildDailyStat(
                                          'Breaks Taken',
                                          '$breaksToday',
                                          Icons.coffee_rounded,
                                          AppTheme.orange,
                                        );
                                      },
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDailyStat(
                                  'Tasks Done',
                                  '$tasksDone',
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
              );
            },
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
        builder: (context) => WorkLogScreen(
          showBackButton: true,
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
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
