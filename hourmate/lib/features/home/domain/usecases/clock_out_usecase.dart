import 'package:equatable/equatable.dart';
import '../entities/work_entry.dart';
import '../repositories/work_entry_repository.dart';

class ClockOutUseCase extends Equatable {
  final WorkEntryRepository repository;

  const ClockOutUseCase({required this.repository});

  Future<WorkEntry> call() async {
    // Get the currently active work entry
    final WorkEntry? activeEntry = await repository.getActiveWorkEntry();
    if (activeEntry == null) {
      throw Exception('No active work session found. Please clock in first.');
    }

    final DateTime now = DateTime.now();
    final WorkEntry updatedEntry = activeEntry.copyWith(endTime: now);

    await repository.updateWorkEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  List<Object?> get props => [repository];
}
