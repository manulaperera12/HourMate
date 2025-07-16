import '../../domain/entities/work_entry.dart';
import '../../domain/repositories/work_entry_repository.dart';
import '../datasources/work_entry_local_datasource.dart';
import '../models/work_entry_model.dart';

class WorkEntryRepositoryImpl implements WorkEntryRepository {
  final WorkEntryLocalDataSource localDataSource;

  WorkEntryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<WorkEntry>> getAllWorkEntries() async {
    final List<WorkEntryModel> models = await localDataSource
        .getAllWorkEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<WorkEntry>> getWorkEntriesByDate(DateTime date) async {
    final List<WorkEntry> allEntries = await getAllWorkEntries();
    return allEntries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  @override
  Future<List<WorkEntry>> getWorkEntriesByWeek(DateTime weekStart) async {
    final List<WorkEntry> allEntries = await getAllWorkEntries();
    final DateTime weekEnd = weekStart.add(const Duration(days: 7));

    return allEntries.where((entry) {
      return entry.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(weekEnd);
    }).toList();
  }

  @override
  Future<WorkEntry?> getActiveWorkEntry() async {
    final List<WorkEntry> allEntries = await getAllWorkEntries();
    try {
      return allEntries.firstWhere((entry) => entry.isActive);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWorkEntry(WorkEntry workEntry) async {
    final WorkEntryModel model = WorkEntryModel.fromEntity(workEntry);
    await localDataSource.saveWorkEntry(model);
  }

  @override
  Future<void> updateWorkEntry(WorkEntry workEntry) async {
    final WorkEntryModel model = WorkEntryModel.fromEntity(workEntry);
    await localDataSource.updateWorkEntry(model);
  }

  @override
  Future<void> deleteWorkEntry(String id) async {
    await localDataSource.deleteWorkEntry(id);
  }

  @override
  Future<double> getTotalHoursForWeek(DateTime weekStart) async {
    final List<WorkEntry> weekEntries = await getWorkEntriesByWeek(weekStart);
    double totalHours = 0.0;

    for (final entry in weekEntries) {
      if (!entry.isActive) {
        totalHours += entry.durationInHours;
      }
    }

    return totalHours;
  }

  @override
  Future<Map<String, int>> getTaskRatingSummaryForWeek(
    DateTime weekStart,
  ) async {
    final List<WorkEntry> weekEntries = await getWorkEntriesByWeek(weekStart);
    final Map<String, int> ratingCounts = {'Good': 0, 'Average': 0, 'Bad': 0};

    for (final entry in weekEntries) {
      if (!entry.isActive) {
        ratingCounts[entry.taskRating] =
            (ratingCounts[entry.taskRating] ?? 0) + 1;
      }
    }

    return ratingCounts;
  }

  @override
  Future<Map<DateTime, double>> getDailyHoursForWeek(DateTime weekStart) async {
    final Map<DateTime, double> dailyHours = {};

    for (int i = 0; i < 7; i++) {
      final DateTime currentDate = weekStart.add(Duration(days: i));
      final List<WorkEntry> dayEntries = await getWorkEntriesByDate(
        currentDate,
      );

      double dayTotalHours = 0.0;
      for (final entry in dayEntries) {
        if (!entry.isActive) {
          dayTotalHours += entry.durationInHours;
        }
      }

      dailyHours[currentDate] = dayTotalHours;
    }

    return dailyHours;
  }
}
