import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import 'weekly_summary_screen.dart';
import 'package:fl_chart/fl_chart.dart';

enum SummaryFilter { workHours, tasks, productivity }

class SummaryScreen extends StatefulWidget {
  final bool showBackButton;
  const SummaryScreen({super.key, this.showBackButton = false});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _selectedTab = 0; // 0 = Chart, 1 = Weekly Summary

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
              ),
              const SizedBox(height: 12),
              _buildTabBar(context),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedTab == 0
                    ? _SummaryChartView()
                    : const WeeklySummaryContent(),
              ),
            ],
          ),
        ),
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
}

class _SummaryChartView extends StatefulWidget {
  @override
  State<_SummaryChartView> createState() => _SummaryChartViewState();
}

class _SummaryChartViewState extends State<_SummaryChartView> {
  bool _perDay = true; // true = per day, false = per hour
  int _selectedDayIndex = 0; // For per-hour mode
  SummaryFilter _selectedFilter = SummaryFilter.workHours;

  @override
  Widget build(BuildContext context) {
    // Mock data for each filter
    final List<double> dailyHours = [6.0, 7.5, 5.0, 8.0, 6.0, 0.0, 0.0];
    final List<double> dailyTasks = [3, 5, 2, 6, 4, 0, 0];
    final List<double> dailyProductivity = [80, 90, 70, 95, 85, 0, 0];
    final List<double> hourlyHours = [
      0,
      0,
      0,
      0,
      0.5,
      1,
      1,
      0.5,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ];
    final List<double> hourlyTasks = [
      0,
      0,
      0,
      0,
      1,
      1,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ];
    final List<double> hourlyProductivity = [
      60,
      70,
      65,
      80,
      90,
      85,
      80,
      75,
      70,
      60,
      65,
      70,
      80,
      85,
      90,
      95,
      80,
      75,
      70,
      60,
      65,
      70,
      80,
      85,
    ];
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
        default:
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
        default:
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
                                default:
                                  label = _perDay
                                      ? '${days[spot.x.toInt()]}: ${spot.y.toStringAsFixed(1)} h'
                                      : '${hours[spot.x.toInt()]}: ${spot.y.toStringAsFixed(1)} h';
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
            color: isSelected ? AppTheme.tabSelected : AppTheme.dividerColor,
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

class _DaySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = ['W', 'T', 'F', 'S', 'S', 'M', 'T'];
    return Row(
      children: days
          .map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                d,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
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

class _NeonLineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxY;
  _NeonLineChartPainter({required this.data, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonYellowGreen
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final dx = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - (data[i] / maxY) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw a second, thinner cyan line for accent
    final accentPaint = Paint()
      ..color = AppTheme.cyanBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final accentPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y =
          size.height - (data[(i + 3) % data.length] / maxY) * size.height;
      if (i == 0) {
        accentPath.moveTo(x, y);
      } else {
        accentPath.lineTo(x, y);
      }
    }
    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
