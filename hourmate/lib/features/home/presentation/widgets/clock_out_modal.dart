import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/work_tracking_bloc.dart';
import '../../domain/entities/work_entry.dart';

class ClockOutModal extends StatefulWidget {
  const ClockOutModal({super.key});

  @override
  State<ClockOutModal> createState() => _ClockOutModalState();
}

class _ClockOutModalState extends State<ClockOutModal> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkTrackingBloc, WorkTrackingState>(
      builder: (context, state) {
        WorkEntry? activeEntry;
        if (state is WorkTrackingLoaded) {
          activeEntry = state.activeWorkEntry;
        }

        if (activeEntry == null) {
          return const SizedBox.shrink();
        }

        final DateTime now = DateTime.now();
        final Duration duration = now.difference(activeEntry.startTime);
        final String formattedDuration =
            '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.disabledTextColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Work Session',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Session Summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppConstants.defaultPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Session Summary',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),

                              // Task Description
                              Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    size: 16,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      activeEntry.taskDescription,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Duration
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Duration: $formattedDuration',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Rating
                              Row(
                                children: [
                                  Icon(
                                    _getRatingIcon(activeEntry.taskRating),
                                    size: 16,
                                    color: _getRatingColor(
                                      activeEntry.taskRating,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rating: ${activeEntry.taskRating}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Final Comment
                      TextFormField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Final Comment (Optional)',
                          hintText: 'How did the session go? Any final notes?',
                          prefixIcon: Icon(Icons.comment),
                        ),
                        maxLines: 3,
                        maxLength: AppConstants.maxCommentLength,
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.defaultPadding),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _clockOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.goodRatingColor,
                              ),
                              child: const Text('End Session'),
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
      },
    );
  }

  IconData _getRatingIcon(String rating) {
    switch (rating) {
      case AppConstants.goodRating:
        return Icons.sentiment_satisfied;
      case AppConstants.averageRating:
        return Icons.sentiment_neutral;
      case AppConstants.badRating:
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case AppConstants.goodRating:
        return AppTheme.goodRatingColor;
      case AppConstants.averageRating:
        return AppTheme.averageRatingColor;
      case AppConstants.badRating:
        return AppTheme.badRatingColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _clockOut() {
    context.read<WorkTrackingBloc>().add(ClockOut());
    Navigator.pop(context);
  }
}
