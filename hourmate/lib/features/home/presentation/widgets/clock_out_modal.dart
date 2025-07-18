import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../work_log/presentation/widgets/rounded_gradient_button.dart';
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2a2a2a), Colors.black],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonYellowGreen.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppTheme.disabledTextColor.withValues(alpha: 0.18),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Neon handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: 54,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.neonYellowGreen,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonYellowGreen.withValues(
                            alpha: 0.45,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'End Work Session',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Session Summary
                        Card(
                          color: const Color(0xFF181818),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
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
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.neonYellowGreen,
                                      ),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Final Comment (Optional)',
                            hintText:
                                'How did the session go? Any final notes?',
                            prefixIcon: const Icon(
                              Icons.comment,
                              color: AppTheme.secondaryTextColor,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.secondaryTextColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.neonYellowGreen,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF181818),
                          ),
                          maxLines: 3,
                          maxLength: AppConstants.maxCommentLength,
                        ),
                        const SizedBox(height: 28),
                        // Action Buttons
                        RoundedGradientButton(
                          text: 'End Session',
                          onPressed: _clockOut,
                        ),
                      ],
                    ),
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
    final bloc = context.read<WorkTrackingBloc>();
    bloc.add(ClockOut());
    Navigator.pop(context);
    // Delay to ensure modal is closed before reloading
    Future.delayed(const Duration(milliseconds: 300), () {
      bloc.add(LoadWorkEntries());
    });
  }
}
