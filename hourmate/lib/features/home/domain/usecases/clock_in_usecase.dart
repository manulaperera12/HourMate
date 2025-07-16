import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../entities/work_entry.dart';
import '../repositories/work_entry_repository.dart';

class ClockInUseCase extends Equatable {
  final WorkEntryRepository repository;
  final Uuid uuid;

  const ClockInUseCase({required this.repository, required this.uuid});

  Future<WorkEntry> call({
    required String taskDescription,
    required String taskRating,
    String? taskComment,
  }) async {
    // Check if there's already an active work entry
    final WorkEntry? activeEntry = await repository.getActiveWorkEntry();
    if (activeEntry != null) {
      throw Exception(
        'There is already an active work session. Please clock out first.',
      );
    }

    final DateTime now = DateTime.now();
    final WorkEntry newEntry = WorkEntry(
      id: uuid.v4(),
      date: DateTime(now.year, now.month, now.day),
      startTime: now,
      taskDescription: taskDescription,
      taskRating: taskRating,
      taskComment: taskComment,
    );

    await repository.saveWorkEntry(newEntry);
    return newEntry;
  }

  @override
  List<Object?> get props => [repository, uuid];
}
