import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/rounded_gradient_header.dart';

class WorkLogScreen extends StatefulWidget {
  final bool showBackButton;
  const WorkLogScreen({super.key, this.showBackButton = false});

  @override
  State<WorkLogScreen> createState() => _WorkLogScreenState();
}

class _WorkLogScreenState extends State<WorkLogScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['Monthly', 'Weekly', 'Daily'];

  @override
  Widget build(BuildContext context) {
    // Single mock data list with dateTime
    final allEntries = [
      {
        'task': 'Client Meeting',
        'duration': '2:15',
        'rating': 'good',
        'comment': 'Discussed project requirements and next steps.',
        'dateTime': DateTime.now(), // today
      },
      {
        'task': 'Code Review',
        'duration': '1:30',
        'rating': 'average',
        'comment': 'Reviewed PRs, left feedback.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 1),
        ), // yesterday
      },
      {
        'task': 'Documentation',
        'duration': '0:45',
        'rating': 'bad',
        'comment': 'Tedious but necessary.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 3),
        ), // this week
      },
      {
        'task': 'Sprint Planning',
        'duration': '3:00',
        'rating': 'good',
        'comment': 'Planned tasks for the week.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 6),
        ), // this week
      },
      {
        'task': 'Bug Fixing',
        'duration': '4:15',
        'rating': 'average',
        'comment': 'Fixed several issues reported by QA.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 10),
        ), // last week
      },
      {
        'task': 'Release Prep',
        'duration': '5:30',
        'rating': 'good',
        'comment': 'Prepared app for release.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 20),
        ), // this month
      },
      {
        'task': 'Retrospective',
        'duration': '2:00',
        'rating': 'average',
        'comment': 'Reviewed what went well and what to improve.',
        'dateTime': DateTime.now().subtract(
          const Duration(days: 32),
        ), // last month
      },
    ];

    final now = DateTime.now();
    List<Map<String, dynamic>> filteredEntries;
    if (selectedTab == 2) {
      // Daily: today only
      filteredEntries = allEntries.where((e) {
        final dt = e['dateTime'] as DateTime;
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      }).toList();
    } else if (selectedTab == 1) {
      // Weekly: entries from this week (Monday-Sunday)
      final weekDay = now.weekday;
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: weekDay - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      filteredEntries = allEntries.where((e) {
        final dt = e['dateTime'] as DateTime;
        return dt.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
    } else {
      // Monthly: entries from this month
      filteredEntries = allEntries.where((e) {
        final dt = e['dateTime'] as DateTime;
        return dt.year == now.year && dt.month == now.month;
      }).toList();
    }

    IconData ratingIcon(String rating) {
      switch (rating) {
        case 'good':
          return Icons.sentiment_satisfied_alt_rounded;
        case 'average':
          return Icons.sentiment_neutral_rounded;
        case 'bad':
          return Icons.sentiment_dissatisfied_rounded;
        default:
          return Icons.sentiment_satisfied_alt_rounded;
      }
    }

    Color ratingColor(String rating) {
      switch (rating) {
        case 'good':
          return AppTheme.goodRatingColor;
        case 'average':
          return AppTheme.averageRatingColor;
        case 'bad':
          return AppTheme.badRatingColor;
        default:
          return AppTheme.goodRatingColor;
      }
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
            stops: [0.0, 0.5, 0.9, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              RoundedGradientHeader(
                title: 'Work Log',
                showBackButton: widget.showBackButton,
                onBack: widget.showBackButton
                    ? () => Navigator.of(context).pop()
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.tabBarBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabs.length, (index) {
                      final isSelected = index == selectedTab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.tabSelected
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                tabs[index],
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppTheme.black
                                          : AppTheme.tabUnselected.withValues(
                                              alpha: 0.7,
                                            ),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return _WorkLogCard(
                      task: entry['task'],
                      duration: entry['duration'],
                      rating: entry['rating'],
                      comment: entry['comment'],
                      ratingIcon: ratingIcon(entry['rating']),
                      ratingColor: ratingColor(entry['rating']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkLogCard extends StatefulWidget {
  final String task;
  final String duration;
  final String rating;
  final String comment;
  final IconData ratingIcon;
  final Color ratingColor;

  const _WorkLogCard({
    required this.task,
    required this.duration,
    required this.rating,
    required this.comment,
    required this.ratingIcon,
    required this.ratingColor,
  });

  @override
  State<_WorkLogCard> createState() => _WorkLogCardState();
}

class _WorkLogCardState extends State<_WorkLogCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.ratingColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.ratingIcon, color: widget.ratingColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.task,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  widget.duration,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            if (widget.comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => expanded = !expanded),
                child: Row(
                  children: [
                    Text(
                      expanded ? 'Hide comment' : 'Show comment',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: widget.ratingColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.ratingColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.comment,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
