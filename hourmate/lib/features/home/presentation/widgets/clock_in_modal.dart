import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
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
        child: Form(
          key: _formKey,
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
                      'Start Work Session',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Task Description
                    TextFormField(
                      controller: _taskDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'What are you working on?',
                        hintText:
                            'e.g., Client meeting, Code review, Documentation',
                        prefixIcon: Icon(Icons.work),
                      ),
                      maxLength: AppConstants.maxTaskDescriptionLength,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Task Rating
                    Text(
                      'How do you feel about this task?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildRatingSelector(),
                    const SizedBox(height: 20),

                    // Optional Comment
                    TextFormField(
                      controller: _taskCommentController,
                      decoration: const InputDecoration(
                        labelText: 'Optional Comment',
                        hintText: 'Any notes, roadblocks, or mood...',
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
                            onPressed: _clockIn,
                            child: const Text('Start Working'),
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
