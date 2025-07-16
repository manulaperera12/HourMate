import 'package:equatable/equatable.dart';

class WorkEntry extends Equatable {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String taskDescription;
  final String taskRating;
  final String? taskComment;

  const WorkEntry({
    required this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.taskDescription,
    required this.taskRating,
    this.taskComment,
  });

  // Check if the work session is currently active
  bool get isActive => endTime == null;

  // Calculate duration in minutes
  int get durationInMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  // Calculate duration in hours
  double get durationInHours {
    if (endTime == null) return 0.0;
    return endTime!.difference(startTime).inMinutes / 60.0;
  }

  // Format duration as HH:MM
  String get formattedDuration {
    if (endTime == null) return '00:00';
    final duration = endTime!.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Create a copy with updated fields
  WorkEntry copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? taskDescription,
    String? taskRating,
    String? taskComment,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      taskDescription: taskDescription ?? this.taskDescription,
      taskRating: taskRating ?? this.taskRating,
      taskComment: taskComment ?? this.taskComment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    startTime,
    endTime,
    taskDescription,
    taskRating,
    taskComment,
  ];

  @override
  String toString() {
    return 'WorkEntry(id: $id, date: $date, startTime: $startTime, endTime: $endTime, taskDescription: $taskDescription, taskRating: $taskRating, taskComment: $taskComment)';
  }
}
