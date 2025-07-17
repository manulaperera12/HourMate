import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../home/data/datasources/work_entry_local_datasource.dart';
import '../../../home/data/models/work_entry_model.dart';
import 'weekly_summary_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

enum SummaryFilter { workHours, tasks, productivity }

class SummaryScreen extends StatefulWidget {
  final bool showBackButton;
  const SummaryScreen({super.key, this.showBackButton = false});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _selectedTab = 0; // 0 = Chart, 1 = Weekly Summary
  DateTime _selectedWeekStart = _getStartOfWeek(DateTime.now());
  bool _loading = true;
  List<WorkEntryModel> _weekEntries = [];

  // Aggregated data
  double _totalHours = 0;
  List<double> _dailyHours = List.filled(7, 0);
  Map<String, int> _ratings = {'Good': 0, 'Average': 0, 'Bad': 0};

  @override
  void initState() {
    super.initState();
    _loadWeekData();
  }

  Future<void> _loadWeekData() async {
    setState(() => _loading = true);
    final dataSource = WorkEntryLocalDataSource();
    final allEntries = await dataSource.getAllEntries();
    final weekEntries = allEntries.where((entry) {
      final start = _selectedWeekStart;
      final end = start.add(const Duration(days: 7));
      return entry.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          entry.date.isBefore(end);
    }).toList();
    // Aggregate
    double totalHours = 0;
    List<double> dailyHours = List.filled(7, 0);
    Map<String, int> ratings = {'Good': 0, 'Average': 0, 'Bad': 0};
    for (final entry in weekEntries) {
      if (entry.endTime != null) {
        final duration =
            entry.endTime!.difference(entry.startTime).inMinutes / 60.0;
        totalHours += duration;
        int dayIdx = entry.date.weekday - 1; // 0=Mon
        if (dayIdx >= 0 && dayIdx < 7) dailyHours[dayIdx] += duration;
      }
      // Count ratings
      if (ratings.containsKey(entry.taskRating)) {
        ratings[entry.taskRating] = ratings[entry.taskRating]! + 1;
      }
    }
    setState(() {
      _weekEntries = weekEntries;
      _totalHours = totalHours;
      _dailyHours = dailyHours;
      _ratings = ratings;
      _loading = false;
    });
  }

  void _changeWeek(int offset) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: 7 * offset));
    });
    _loadWeekData();
  }

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
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
          child: Column(
            children: [
              AppHeader(
                title: 'Summary',
                subtitle: 'Visualize your weekly work stats',
                showBackButton: widget.showBackButton,
                onBack: () => Navigator.of(context).pop(),
                onAvatarTap: _navigateToProfile,
              ),
              _buildWeekSelector(context),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildTabBar(context),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _selectedTab == 0
                                  ? _SummaryChartView(
                                      weekEntries: _weekEntries,
                                      dailyHours: _dailyHours,
                                    )
                                  : WeeklySummaryContent(
                                      totalHours: _totalHours,
                                      dailyHours: _dailyHours,
                                      ratings: _ratings,
                                    ),
                            ),
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

  Widget _buildWeekSelector(BuildContext context) {
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    final weekLabel =
        '${formatter.format(_selectedWeekStart)} – ${formatter.format(weekEnd)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppTheme.neonYellowGreen,
            ),
            onPressed: () => _changeWeek(-1),
          ),
          Text(
            weekLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppTheme.neonYellowGreen,
            ),
            onPressed: () => _changeWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.tabBarBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [_buildTabButton('Chart', 0), _buildTabButton('Weekly', 1)],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.tabSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? AppTheme.black
                    : AppTheme.tabUnselected.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
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
}

// Refactor WeeklySummaryContent to accept totalHours, dailyHours, and ratings
class WeeklySummaryContent extends StatelessWidget {
  final double totalHours;
  final List<double> dailyHours;
  final Map<String, int> ratings;
  const WeeklySummaryContent({
    super.key,
    required this.totalHours,
    required this.dailyHours,
    required this.ratings,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Total hours
        Text(
          '${totalHours.toStringAsFixed(1)} h',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.neonYellowGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'Asap',
            fontSize: 38,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Total hours this week',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.secondaryTextColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        // Bar chart
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF2C2C2C),
                Color(0xFF1A1A1A).withValues(alpha: 0.5),
                Color(0xFF0D0D0D).withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonYellowGreen.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 16,
                    height: (dailyHours[i] / 8.0) * 60 + 8, // max 8h
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.headerGradientEnd,
                          AppTheme.headerGradientStart,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 28),
        // Task rating summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RatingChip(
                label: 'Good',
                count: ratings['Good'] ?? 0,
                color: AppTheme.goodRatingColor,
                icon: Icons.sentiment_satisfied_alt_rounded,
              ),
              _RatingChip(
                label: 'Average',
                count: ratings['Average'] ?? 0,
                color: AppTheme.averageRatingColor,
                icon: Icons.sentiment_neutral_rounded,
              ),
              _RatingChip(
                label: 'Bad',
                count: ratings['Bad'] ?? 0,
                color: AppTheme.badRatingColor,
                icon: Icons.sentiment_dissatisfied_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

// Move _RatingChip above WeeklySummaryContent so it is in scope
class _RatingChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _RatingChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            ' $count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// Refactor _SummaryChartView to accept weekEntries and dailyHours
class _SummaryChartView extends StatefulWidget {
  final List<WorkEntryModel> weekEntries;
  final List<double> dailyHours;

  const _SummaryChartView({
    required this.weekEntries,
    required this.dailyHours,
  });

  @override
  State<_SummaryChartView> createState() => _SummaryChartViewState();
}

class _SummaryChartViewState extends State<_SummaryChartView> {
  bool _perDay = true; // true = per day, false = per hour
  int _selectedDayIndex = 0; // For per-hour mode
  SummaryFilter _selectedFilter = SummaryFilter.workHours;

  // Helper to map rating string to numeric value
  int _ratingToValue(String rating) {
    switch (rating) {
      case 'Good':
        return 100;
      case 'Average':
        return 60;
      case 'Bad':
        return 20;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> dailyHours = widget.dailyHours;
    // --- Tasks and Productivity Aggregation ---
    // Per Day
    List<double> dailyTasks = List.filled(7, 0);
    List<double> dailyProductivity = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final day = i + 1; // weekday: 1=Mon
      final entriesForDay = widget.weekEntries
          .where((e) => e.date.weekday == day && e.endTime != null)
          .toList();
      dailyTasks[i] = entriesForDay.length.toDouble();
      if (entriesForDay.isNotEmpty) {
        final ratings = entriesForDay
            .map((e) => _ratingToValue(e.taskRating))
            .toList();
        dailyProductivity[i] = ratings.reduce((a, b) => a + b) / ratings.length;
      }
    }
    // Per Hour (for selected day)
    List<double> hourlyHours = List.filled(24, 0);
    List<double> hourlyTasks = List.filled(24, 0);
    List<double> hourlyProductivity = List.filled(24, 0);
    if (!_perDay && widget.weekEntries.isNotEmpty) {
      final selectedDay = _selectedDayIndex + 1; // weekday: 1=Mon
      final entriesForDay = widget.weekEntries
          .where((e) => e.date.weekday == selectedDay && e.endTime != null)
          .toList();
      List<List<int>> productivityBuckets = List.generate(24, (_) => []);
      for (final entry in entriesForDay) {
        int startHour = entry.startTime.hour;
        double duration =
            entry.endTime!.difference(entry.startTime).inMinutes / 60.0;
        if (startHour >= 0 && startHour < 24) {
          hourlyHours[startHour] += duration;
          hourlyTasks[startHour] += 1;
          productivityBuckets[startHour].add(_ratingToValue(entry.taskRating));
        }
      }
      for (int h = 0; h < 24; h++) {
        if (productivityBuckets[h].isNotEmpty) {
          hourlyProductivity[h] =
              productivityBuckets[h].reduce((a, b) => a + b) /
              productivityBuckets[h].length;
        }
      }
    }
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> hours = [
      '00',
      '01',
      '02',
      '03',
      '04',
      '05',
      '06',
      '07',
      '08',
      '09',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
    ];
    final double maxY = _selectedFilter == SummaryFilter.productivity
        ? 100
        : 10;

    List<double> getCurrentDaily() {
      switch (_selectedFilter) {
        case SummaryFilter.tasks:
          return dailyTasks;
        case SummaryFilter.productivity:
          return dailyProductivity;
        case SummaryFilter.workHours:
          return dailyHours;
      }
    }

    List<double> getCurrentHourly() {
      switch (_selectedFilter) {
        case SummaryFilter.tasks:
          return hourlyTasks;
        case SummaryFilter.productivity:
          return hourlyProductivity;
        case SummaryFilter.workHours:
          return hourlyHours;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0, // Adjust radius to control the spread of the gradient
            colors: [
              Color(0xFF2C2C2C), // Dark grey for the center
              Color(0xFF1A1A1A).withValues(
                alpha: 0.5,
              ), // Slightly darker grey for the outer part
              Color(0xFF0D0D0D).withValues(
                alpha: 0.0,
              ), // Even darker, almost black for the edges
            ],
            stops: const [0.0, 0.5, 1.0], // Control where each color stops
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonYellowGreen.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 18),
              // Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton(context, 'Per Day', true),
                  const SizedBox(width: 12),
                  _buildToggleButton(context, 'Per Hour', false),
                ],
              ),
              const SizedBox(height: 18),
              // Day selector for per-hour mode
              if (!_perDay)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        days.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              days[i],
                              style: TextStyle(
                                color: _selectedDayIndex == i
                                    ? AppTheme.black
                                    : AppTheme.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: _selectedDayIndex == i,
                            selectedColor: AppTheme.neonYellowGreen,
                            backgroundColor: AppTheme.cardColor,
                            side: BorderSide(
                              color: _selectedDayIndex == i
                                  ? AppTheme.neonYellowGreen
                                  : AppTheme.disabledTextColor,
                              width: 1.5,
                            ),
                            onSelected: (selected) {
                              setState(() => _selectedDayIndex = i);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!_perDay) const SizedBox(height: 12),
              // Chart
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.dividerColor.withValues(alpha: 0.18),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) => Text(
                              value == 0 ? '' : value.toInt().toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 11,
                                  ),
                            ),
                            interval:
                                _selectedFilter == SummaryFilter.productivity
                                ? 20
                                : 2,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (_perDay) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      days[idx],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.secondaryTextColor,
                                            fontSize: 11,
                                          ),
                                    ),
                                  );
                                }
                              } else {
                                int idx = value.toInt();
                                if (idx % 2 == 0 && idx ~/ 2 < hours.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      hours[idx],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.secondaryTextColor,
                                            fontSize: 11,
                                          ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _perDay
                              ? List.generate(
                                  getCurrentDaily().length,
                                  (i) => FlSpot(
                                    i.toDouble(),
                                    getCurrentDaily()[i],
                                  ),
                                )
                              : List.generate(
                                  getCurrentHourly().length,
                                  (i) => FlSpot(
                                    i.toDouble(),
                                    getCurrentHourly()[i],
                                  ),
                                ),
                          isCurved: true,
                          color: _selectedFilter == SummaryFilter.productivity
                              ? AppTheme.cyanBlue
                              : AppTheme.neonYellowGreen,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                (_selectedFilter == SummaryFilter.productivity
                                        ? AppTheme.cyanBlue
                                        : AppTheme.neonYellowGreen)
                                    .withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 6,
                                  color:
                                      _selectedFilter ==
                                          SummaryFilter.productivity
                                      ? AppTheme.cyanBlue
                                      : AppTheme.neonYellowGreen,
                                  strokeWidth: 2,
                                  strokeColor: AppTheme.cardColor,
                                ),
                          ),
                        ),
                        // Accent line (cyan)
                        LineChartBarData(
                          spots: _perDay
                              ? List.generate(
                                  getCurrentDaily().length,
                                  (i) => FlSpot(
                                    i.toDouble(),
                                    (getCurrentDaily()[i] * 0.8).clamp(0, maxY),
                                  ),
                                )
                              : List.generate(
                                  getCurrentHourly().length,
                                  (i) => FlSpot(
                                    i.toDouble(),
                                    (getCurrentHourly()[i] * 0.8).clamp(
                                      0,
                                      maxY,
                                    ),
                                  ),
                                ),
                          isCurved: true,
                          color: AppTheme.cyanBlue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBorderRadius: BorderRadius.circular(12),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              String label;
                              switch (_selectedFilter) {
                                case SummaryFilter.tasks:
                                  label = _perDay
                                      ? '${days[spot.x.toInt()]}: ${spot.y.toStringAsFixed(0)} tasks'
                                      : '${hours[spot.x.toInt()]}: ${spot.y.toStringAsFixed(0)} tasks';
                                  break;
                                case SummaryFilter.productivity:
                                  label = _perDay
                                      ? '${days[spot.x.toInt()]}: ${spot.y.toStringAsFixed(0)}%'
                                      : '${hours[spot.x.toInt()]}: ${spot.y.toStringAsFixed(0)}%';
                                  break;
                                case SummaryFilter.workHours:
                                  label = _perDay
                                      ? '${days[spot.x.toInt()]}: ${spot.y.toStringAsFixed(1)} h'
                                      : '${hours[spot.x.toInt()]}: ${spot.y.toStringAsFixed(1)} h';
                                  break;
                              }
                              return LineTooltipItem(
                                label,
                                TextStyle(
                                  color:
                                      _selectedFilter ==
                                          SummaryFilter.productivity
                                      ? AppTheme.cyanBlue
                                      : AppTheme.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // X axis labels (scrollable for per-hour)
              if (!_perDay)
                SizedBox(
                  height: 24,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: hours
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                h,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Filter bar (functional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FilterChip(
                    label: 'Work Hours',
                    selected: _selectedFilter == SummaryFilter.workHours,
                    onTap: () => setState(
                      () => _selectedFilter = SummaryFilter.workHours,
                    ),
                  ),
                  _FilterChip(
                    label: 'Tasks',
                    selected: _selectedFilter == SummaryFilter.tasks,
                    onTap: () =>
                        setState(() => _selectedFilter = SummaryFilter.tasks),
                  ),
                  _FilterChip(
                    label: 'Productivity',
                    selected: _selectedFilter == SummaryFilter.productivity,
                    onTap: () => setState(
                      () => _selectedFilter = SummaryFilter.productivity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String label, bool perDay) {
    final isSelected = _perDay == perDay;
    return GestureDetector(
      onTap: () => setState(() => _perDay = perDay),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tabSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppTheme.tabSelected
                : AppTheme.disabledTextColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.neonYellowGreen.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? AppTheme.black : AppTheme.secondaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _FilterChip({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonYellowGreen : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.neonYellowGreen : AppTheme.dividerColor,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.neonYellowGreen.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            if (selected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.black,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppTheme.black : AppTheme.secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
