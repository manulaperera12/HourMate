import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../work_log/presentation/widgets/rounded_gradient_button.dart';
import '../blocs/work_tracking_bloc.dart';

class ClockInModal extends StatefulWidget {
  const ClockInModal({super.key});

  @override
  State<ClockInModal> createState() => _ClockInModalState();
}

class _ClockInModalState extends State<ClockInModal> {
  final _formKey = GlobalKey<FormState>();
  final _taskDescriptionController = TextEditingController();
  final _taskCommentController = TextEditingController();
  String _selectedRating = AppConstants.goodRating;

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    _taskCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2a2a2a), Colors.black],
        ),
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
        child: Form(
          key: _formKey,
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
                        color: AppTheme.neonYellowGreen.withOpacity(0.45),
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
                          'Start Work Session',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Task Description
                      TextFormField(
                        controller: _taskDescriptionController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'What are you working on?',
                          hintText:
                              'e.g., Client meeting, Code review, Documentation',
                          prefixIcon: const Icon(
                            Icons.work,
                            color: AppTheme.secondaryTextColor,
                          ),
                          labelStyle: const TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppTheme.disabledTextColor,
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
                        maxLength: AppConstants.maxTaskDescriptionLength,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      // Task Rating
                      Text(
                        'How do you feel about this task?',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _buildRatingSelector(),
                      const SizedBox(height: 18),
                      // Optional Comment
                      TextFormField(
                        controller: _taskCommentController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Optional Comment',
                          hintText: 'Any notes, roadblocks, or mood...',
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
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.2,
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
                        text: 'Start Session',
                        onPressed: _clockIn,
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

  Widget _buildRatingSelector() {
    return Row(
      children: AppConstants.taskRatingOptions.map((rating) {
        final isSelected = _selectedRating == rating;
        Color color;
        IconData icon;

        switch (rating) {
          case AppConstants.goodRating:
            color = AppTheme.goodRatingColor;
            icon = Icons.sentiment_satisfied;
            break;
          case AppConstants.averageRating:
            color = AppTheme.averageRatingColor;
            icon = Icons.sentiment_neutral;
            break;
          case AppConstants.badRating:
            color = AppTheme.badRatingColor;
            icon = Icons.sentiment_dissatisfied;
            break;
          default:
            color = AppTheme.primaryColor;
            icon = Icons.sentiment_satisfied;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRating = rating),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? color : AppTheme.disabledTextColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rating,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? color : AppTheme.disabledTextColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _clockIn() {
    if (_formKey.currentState!.validate()) {
      context.read<WorkTrackingBloc>().add(
        ClockIn(
          taskDescription: _taskDescriptionController.text.trim(),
          taskRating: _selectedRating,
          taskComment: _taskCommentController.text.trim().isEmpty
              ? null
              : _taskCommentController.text.trim(),
        ),
      );
      Navigator.pop(context);
    }
  }
}
