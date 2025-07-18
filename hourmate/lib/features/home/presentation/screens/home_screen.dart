import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/productivity_calculator.dart';
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
import '../widgets/goal_modal.dart';
import '../widgets/productivity_insights_card.dart';
import '../../../work_log/presentation/screens/work_log_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../home/domain/usecases/get_work_entries_usecase.dart';
import 'package:intl/intl.dart';
import '../../../home/domain/entities/work_entry.dart';
import '../../../../core/services/settings_service.dart';
import '../widgets/break_timer_card.dart';
import '../../data/datasources/work_entry_local_datasource.dart';

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
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _showDateFilter = false;

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
    // Clear corrupted work entry data on startup
    WorkEntryLocalDataSource.clearCorruptedWorkEntries().then((_) {
      _loadCustomGoals();
      context.read<WorkTrackingBloc>().add(LoadWorkEntries());
      context.read<WorkTrackingBloc>().add(RestoreBreak());
    });
  }

  Future<void> _loadCustomGoals() async {
    final goals = await SettingsService.getCustomGoals();
    setState(() {
      _customGoals = goals;
    });
  }

  List<Map<String, dynamic>> _getFilteredGoals() {
    if (!_showDateFilter ||
        (_filterStartDate == null && _filterEndDate == null)) {
      return _customGoals;
    }

    return _customGoals.where((goal) {
      final goalStartDate = goal['startDate'] != null
          ? DateTime.tryParse(goal['startDate'])
          : null;
      final goalEndDate = goal['endDate'] != null
          ? DateTime.tryParse(goal['endDate'])
          : null;

      // If goal has no dates, include it
      if (goalStartDate == null && goalEndDate == null) {
        return true;
      }

      // Check if goal overlaps with filter range
      if (_filterStartDate != null && _filterEndDate != null) {
        // Filter has both start and end dates
        if (goalStartDate != null && goalEndDate != null) {
          // Goal has both dates - check overlap
          return !(goalEndDate.isBefore(_filterStartDate!) ||
              goalStartDate.isAfter(_filterEndDate!));
        } else if (goalStartDate != null) {
          // Goal has only start date
          return !goalStartDate.isAfter(_filterEndDate!);
        } else if (goalEndDate != null) {
          // Goal has only end date
          return !goalEndDate.isBefore(_filterStartDate!);
        }
      } else if (_filterStartDate != null) {
        // Filter has only start date
        if (goalEndDate != null) {
          return !goalEndDate.isBefore(_filterStartDate!);
        }
      } else if (_filterEndDate != null) {
        // Filter has only end date
        if (goalStartDate != null) {
          return !goalStartDate.isAfter(_filterEndDate!);
        }
      }

      return true;
    }).toList();
  }

  Future<void> _selectFilterDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_filterStartDate ?? DateTime.now())
          : (_filterEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonYellowGreen,
              onPrimary: Colors.black,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.primaryTextColor,
            ),
            dialogBackgroundColor: AppTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filterStartDate = picked;
          if (_filterEndDate != null && _filterEndDate!.isBefore(picked)) {
            _filterEndDate = null;
          }
        } else {
          _filterEndDate = picked;
        }
      });
    }
  }

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
            stops: [0.0, 0.5, 0.9, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<WorkTrackingBloc, WorkTrackingState>(
            listener: (context, state) {
              // No SnackBar for WorkTrackingError
            },
            builder: (context, state) {
              if (state is WorkTrackingError) {
                // Show a loading indicator or fallback UI instead of error
                return const Center(child: CircularProgressIndicator());
              }
              if (state is! WorkTrackingLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WorkTrackingLoaded) {
                return CustomScrollView(
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
                        child: HomeHeader(
                          dateRange: _currentWeekRange,
                          onSettingsTap: _navigateToSettings,
                          onAvatarTap: _navigateToProfile,
                          showBackButton: widget.showBackButton,
                          onBack: () => Navigator.of(context).pop(),
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
                        child: HomeTabBar(
                          selectedIndex: _selectedTab,
                          onTabSelected: (index) {
                            setState(() => _selectedTab = index);
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: const SizedBox(height: 30)),
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildTabContent(_selectedTab, state),
                      ),
                    ),
                    SliverToBoxAdapter(child: const SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: ClockInOutButton(
                        isClockInEnabled: state.isClockInEnabled,
                        activeWorkEntry: state.activeWorkEntry,
                        onClockIn: _showClockInModal,
                        onClockOut: _showClockOutModal,
                      ),
                    ),
                    if (state.activeWorkEntry != null)
                      SliverToBoxAdapter(
                        child: WorkStatusCard(
                          workEntry: state.activeWorkEntry!,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: QuickActions(
                          onViewLog: () => _navigateToWorkLog(),
                          onViewSummary: () => _navigateToWeeklySummary(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          final state = context.watch<WorkTrackingBloc>().state;
                          if (state is! WorkTrackingLoaded) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return BreakTimerCard(
                            isOnBreak: state.isOnBreak,
                            breakDurationMinutes: state.breakDurationMinutes,
                            breakElapsedSeconds: state.breakElapsedSeconds,
                            breakRemainingSeconds: state.breakRemainingSeconds,
                            defaultDuration: state.breakDurationMinutes ?? 15,
                            onDurationChanged: (v) {
                              context.read<WorkTrackingBloc>().add(
                                UpdateBreakDuration(durationMinutes: v),
                              );
                            },
                            onStartBreak: () {
                              if (!(state.isOnBreak ?? false)) {
                                context.read<WorkTrackingBloc>().add(
                                  StartBreak(
                                    durationMinutes:
                                        state.breakDurationMinutes ?? 15,
                                  ),
                                );
                              }
                            },
                            onEndBreak: () {
                              context.read<WorkTrackingBloc>().add(
                                const EndBreak(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: _buildTodaySummary(state.workEntries),
                      ),
                    ),
                    SliverToBoxAdapter(child: const SizedBox(height: 100)),
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
    // Defensive: filter out non-WorkEntry entries
    final List<WorkEntry> safeEntries = workEntries
        .where((e) => e is WorkEntry)
        .cast<WorkEntry>()
        .toList();
    final DateTime today = DateTime.now();
    final List<WorkEntry> todayEntries = safeEntries.where((entry) {
      try {
        return entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day;
      } catch (e) {
        debugPrint('Error in todayEntries filter: $e');
        return false;
      }
    }).toList();

    double totalHours = 0.0;
    for (final entry in todayEntries) {
      try {
        if (!entry.isActive) {
          totalHours += (entry.durationInHours is int)
              ? (entry.durationInHours as int).toDouble()
              : entry.durationInHours;
        }
      } catch (e) {
        debugPrint('Error summing totalHours: $e');
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
    // Defensive: ensure state.workEntries is Iterable and filter out non-WorkEntry
    final workEntries =
        (state is WorkTrackingLoaded && state.workEntries is Iterable)
        ? state.workEntries
              .where((e) => e is WorkEntry)
              .cast<WorkEntry>()
              .toList()
        : <WorkEntry>[];
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
            final hours = workEntries
                .where(
                  (entry) =>
                      entry.date.year == date.year &&
                      entry.date.month == date.month &&
                      entry.date.day == date.day &&
                      !entry.isActive,
                )
                .fold<double>(0.0, (sum, entry) {
                  try {
                    return sum +
                        (entry.durationInHours is int
                            ? (entry.durationInHours as int).toDouble()
                            : entry.durationInHours);
                  } catch (e) {
                    debugPrint('Error in weekProgress fold: $e');
                    return sum;
                  }
                });
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
          final todayEntries = workEntries
              .where(
                (entry) =>
                    entry.date.year == today.year &&
                    entry.date.month == today.month &&
                    entry.date.day == today.day &&
                    !entry.isActive,
              )
              .toList();
          workedDuration = Duration(
            minutes: todayEntries.fold<int>(0, (sum, entry) {
              try {
                return sum + (entry.durationInMinutes as num).toInt();
              } catch (e) {
                debugPrint('Error in workedDuration fold: $e');
                return sum;
              }
            }),
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

              // Use advanced productivity calculation
              final productivityInsights =
                  ProductivityCalculator.getProductivityInsights(
                    todayEntries,
                    goalDuration.inHours.toDouble(),
                  );
              final productivityScore = (productivityInsights['score'] as num)
                  .toInt();
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
                        const SizedBox(height: 20),
                        ProductivityInsightsCard(
                          entries: todayEntries,
                          dailyGoal: goalDuration.inHours.toDouble(),
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
                final hours = workEntries
                    .where(
                      (entry) =>
                          entry.date.year == date.year &&
                          entry.date.month == date.month &&
                          entry.date.day == date.day &&
                          !entry.isActive,
                    )
                    .fold<double>(
                      0.0,
                      (sum, entry) =>
                          sum +
                          (entry.durationInHours is int
                              ? (entry.durationInHours as int).toDouble()
                              : entry.durationInHours),
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
                    // Goals & Tasks Section
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonYellowGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Goals & Tasks',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.neonYellowGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _showDateFilter
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_outlined,
                                  color: AppTheme.cyanBlue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showDateFilter = !_showDateFilter;
                                    if (!_showDateFilter) {
                                      _filterStartDate = null;
                                      _filterEndDate = null;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppTheme.neonYellowGreen,
                                ),
                                onPressed: () => _showAddGoalModal(context),
                              ),
                            ],
                          ),
                          if (_showDateFilter) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () =>
                                              _selectFilterDate(context, true),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withValues(alpha: 0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 16,
                                                  color:
                                                      AppTheme.neonYellowGreen,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _filterStartDate != null
                                                        ? DateFormat(
                                                            'MMM dd, yyyy',
                                                          ).format(
                                                            _filterStartDate!,
                                                          )
                                                        : 'Start Date',
                                                    style: TextStyle(
                                                      color:
                                                          _filterStartDate !=
                                                              null
                                                          ? AppTheme
                                                                .primaryTextColor
                                                          : AppTheme
                                                                .secondaryTextColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () =>
                                              _selectFilterDate(context, false),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withValues(alpha: 0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.event,
                                                  size: 16,
                                                  color: AppTheme.cyanBlue,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _filterEndDate != null
                                                        ? DateFormat(
                                                            'MMM dd, yyyy',
                                                          ).format(
                                                            _filterEndDate!,
                                                          )
                                                        : 'End Date',
                                                    style: TextStyle(
                                                      color:
                                                          _filterEndDate != null
                                                          ? AppTheme
                                                                .primaryTextColor
                                                          : AppTheme
                                                                .secondaryTextColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_filterStartDate != null ||
                                      _filterEndDate != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _filterStartDate = null;
                                                _filterEndDate = null;
                                              });
                                            },
                                            child: Text(
                                              'Clear Filter',
                                              style: TextStyle(
                                                color: AppTheme.errorColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_getFilteredGoals().length} goals',
                                          style: TextStyle(
                                            color: AppTheme.secondaryTextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
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
                            ..._getFilteredGoals().asMap().entries.map((entry) {
                              final filteredIndex = entry.key;
                              final goal = entry.value;
                              // Find the original index in _customGoals
                              final originalIndex = _customGoals.indexWhere(
                                (g) => g['title'] == goal['title'],
                              );
                              final i = originalIndex >= 0
                                  ? originalIndex
                                  : filteredIndex;
                              final startDate = goal['startDate'] != null
                                  ? DateTime.tryParse(goal['startDate'])
                                  : null;
                              final endDate = goal['endDate'] != null
                                  ? DateTime.tryParse(goal['endDate'])
                                  : null;

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
                                child: Column(
                                  children: [
                                    Row(
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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                goal['title'] ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      decoration:
                                                          goal['completed'] ==
                                                              true
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                      color: AppTheme
                                                          .primaryTextColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              if (startDate != null ||
                                                  endDate != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      if (startDate !=
                                                          null) ...[
                                                        Icon(
                                                          Icons.calendar_today,
                                                          size: 12,
                                                          color: AppTheme
                                                              .secondaryTextColor,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                            'MMM dd',
                                                          ).format(startDate!),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .secondaryTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                      if (startDate != null &&
                                                          endDate != null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 4,
                                                              ),
                                                          child: Text(
                                                            '→',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .secondaryTextColor,
                                                            ),
                                                          ),
                                                        ),
                                                      if (endDate != null) ...[
                                                        Icon(
                                                          Icons.event,
                                                          size: 12,
                                                          color: AppTheme
                                                              .secondaryTextColor,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                            'MMM dd',
                                                          ).format(endDate!),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .secondaryTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: AppTheme.secondaryTextColor,
                                          ),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              _showEditGoalModal(
                                                context,
                                                i,
                                                goal,
                                              );
                                            } else if (value == 'delete') {
                                              await SettingsService.removeCustomGoal(
                                                i,
                                              );
                                              await _loadCustomGoals();
                                              setState(() {});
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: AppTheme
                                                        .neonYellowGreen,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: AppTheme.errorColor,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
              // Use advanced productivity calculation for Focus Score
              final dailyGoal = (state is WorkTrackingLoaded)
                  ? state.dailyGoal
                  : 8.0;
              final productivityInsights =
                  ProductivityCalculator.getProductivityInsights(
                    todayEntries,
                    dailyGoal,
                  );
              final productivityScore = (productivityInsights['score'] as num)
                  .toInt();
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
        builder: (context) => SettingsScreen(
          showBackButton: true,
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
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

  void _showAddGoalModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalModal(),
    );

    if (result != null) {
      final startDate = result['startDate'] != null
          ? DateTime.tryParse(result['startDate'])
          : null;
      final endDate = result['endDate'] != null
          ? DateTime.tryParse(result['endDate'])
          : null;

      await SettingsService.addCustomGoal(
        result['title'],
        startDate: startDate,
        endDate: endDate,
      );
      await _loadCustomGoals();
      setState(() {});
    }
  }

  void _showEditGoalModal(
    BuildContext context,
    int index,
    Map<String, dynamic> goal,
  ) async {
    final startDate = goal['startDate'] != null
        ? DateTime.tryParse(goal['startDate'])
        : null;
    final endDate = goal['endDate'] != null
        ? DateTime.tryParse(goal['endDate'])
        : null;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalModal(
        initialTitle: goal['title'],
        initialStartDate: startDate,
        initialEndDate: endDate,
        isEditing: true,
      ),
    );

    if (result != null) {
      final newStartDate = result['startDate'] != null
          ? DateTime.tryParse(result['startDate'])
          : null;
      final newEndDate = result['endDate'] != null
          ? DateTime.tryParse(result['endDate'])
          : null;

      await SettingsService.updateCustomGoal(
        index,
        title: result['title'],
        startDate: newStartDate,
        endDate: newEndDate,
      );
      await _loadCustomGoals();
      setState(() {});
    }
  }
}
