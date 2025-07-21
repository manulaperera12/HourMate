import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/work_entry.dart';
import '../blocs/work_log_bloc.dart';
import '../../../home/domain/usecases/get_work_entries_usecase.dart';
// import '../widgets/rounded_gradient_header.dart';

class WorkLogScreen extends StatefulWidget {
  final bool showBackButton;
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  const WorkLogScreen({
    super.key,
    this.showBackButton = false,
    required this.getWorkEntriesUseCase,
  });

  @override
  State<WorkLogScreen> createState() => _WorkLogScreenState();
}

class _WorkLogScreenState extends State<WorkLogScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['Monthly', 'Weekly', 'Daily'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WorkLogBloc(getWorkEntriesUseCase: widget.getWorkEntriesUseCase)
            ..add(LoadWorkLogEntries()),
      child: BlocBuilder<WorkLogBloc, WorkLogState>(
        builder: (context, state) {
          if (state is WorkLogLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WorkLogError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          List<WorkEntry> allEntries = [];
          if (state is WorkLogLoaded) {
            allEntries = state.entries;
          }
          final now = DateTime.now();
          List<WorkEntry> filteredEntries;
          if (selectedTab == 2) {
            filteredEntries = allEntries
                .where(
                  (e) =>
                      e.date.year == now.year &&
                      e.date.month == now.month &&
                      e.date.day == now.day,
                )
                .toList();
          } else if (selectedTab == 1) {
            final weekDay = now.weekday;
            final startOfWeek = DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(Duration(days: weekDay - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 6));
            filteredEntries = allEntries
                .where(
                  (e) =>
                      e.date.isAfter(
                        startOfWeek.subtract(const Duration(seconds: 1)),
                      ) &&
                      e.date.isBefore(endOfWeek.add(const Duration(days: 1))),
                )
                .toList();
          } else {
            filteredEntries = allEntries
                .where(
                  (e) => e.date.year == now.year && e.date.month == now.month,
                )
                .toList();
          }

          IconData ratingIcon(String rating) {
            switch (rating.toLowerCase()) {
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
            switch (rating.toLowerCase()) {
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
                          title: 'Work Log',
                          subtitle: 'View and filter your work sessions',
                          showBackButton: widget.showBackButton,
                          onBack: widget.showBackButton
                              ? () => Navigator.of(context).pop()
                              : null,
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
                            Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(tabs.length, (index) {
                                  final isSelected = index == selectedTab;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => selectedTab = index),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.ease,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.tabSelected
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            tabs[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? AppTheme.black
                                                      : AppTheme.tabUnselected
                                                            .withValues(
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
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredEntries.length,
                              itemBuilder: (context, index) {
                                final entry = filteredEntries[index];
                                return _WorkLogCard(
                                  task: entry.taskDescription,
                                  duration: entry.formattedDuration,
                                  rating: entry.taskRating,
                                  comment: entry.taskComment ?? '',
                                  ratingIcon: ratingIcon(entry.taskRating),
                                  ratingColor: ratingColor(entry.taskRating),
                                );
                              },
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
        },
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
