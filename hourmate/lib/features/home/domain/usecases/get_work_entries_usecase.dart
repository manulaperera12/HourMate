import 'package:equatable/equatable.dart';
import '../entities/work_entry.dart';
import '../repositories/work_entry_repository.dart';

class GetWorkEntriesUseCase extends Equatable {
  final WorkEntryRepository repository;

  const GetWorkEntriesUseCase({required this.repository});

  Future<List<WorkEntry>> call() async {
    return await repository.getAllWorkEntries();
  }

  Future<List<WorkEntry>> getByDate(DateTime date) async {
    return await repository.getWorkEntriesByDate(date);
  }

  Future<List<WorkEntry>> getByWeek(DateTime weekStart) async {
    return await repository.getWorkEntriesByWeek(weekStart);
  }

  Future<WorkEntry?> getActiveEntry() async {
    return await repository.getActiveWorkEntry();
  }

  @override
  List<Object?> get props => [repository];
}
