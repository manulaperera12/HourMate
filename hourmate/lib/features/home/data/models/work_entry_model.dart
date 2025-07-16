import '../../domain/entities/work_entry.dart';

class WorkEntryModel extends WorkEntry {
  const WorkEntryModel({
    required super.id,
    required super.date,
    required super.startTime,
    super.endTime,
    required super.taskDescription,
    required super.taskRating,
    super.taskComment,
  });

  // Convert entity to model
  factory WorkEntryModel.fromEntity(WorkEntry entity) {
    return WorkEntryModel(
      id: entity.id,
      date: entity.date,
      startTime: entity.startTime,
      endTime: entity.endTime,
      taskDescription: entity.taskDescription,
      taskRating: entity.taskRating,
      taskComment: entity.taskComment,
    );
  }

  // Convert model to entity
  WorkEntry toEntity() {
    return WorkEntry(
      id: id,
      date: date,
      startTime: startTime,
      endTime: endTime,
      taskDescription: taskDescription,
      taskRating: taskRating,
      taskComment: taskComment,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'taskDescription': taskDescription,
      'taskRating': taskRating,
      'taskComment': taskComment,
    };
  }

  // Create from JSON
  factory WorkEntryModel.fromJson(Map<String, dynamic> json) {
    return WorkEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      taskDescription: json['taskDescription'] as String,
      taskRating: json['taskRating'] as String,
      taskComment: json['taskComment'] as String?,
    );
  }

  // Create a copy with updated fields
  @override
  WorkEntryModel copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? taskDescription,
    String? taskRating,
    String? taskComment,
  }) {
    return WorkEntryModel(
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
}
