import 'dart:convert';
import '../../domain/entities/work_entry.dart';

class WorkEntryModel {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String taskDescription;
  final String taskRating;
  final String? taskComment;

  WorkEntryModel({
    required this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.taskDescription,
    required this.taskRating,
    this.taskComment,
  });

  Map<String, dynamic> toMap() {
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

  factory WorkEntryModel.fromMap(Map<String, dynamic> map) {
    return WorkEntryModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      taskDescription: map['taskDescription'],
      taskRating: map['taskRating'],
      taskComment: map['taskComment'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkEntryModel.fromJson(String source) =>
      WorkEntryModel.fromMap(json.decode(source));

  // Conversion from domain entity to model
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

  // Conversion from model to domain entity
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
}
