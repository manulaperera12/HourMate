import '../entities/work_entry.dart';

abstract class WorkEntryRepository {
  // Get all work entries
  Future<List<WorkEntry>> getAllWorkEntries();

  // Get work entries for a specific date
  Future<List<WorkEntry>> getWorkEntriesByDate(DateTime date);

  // Get work entries for a specific week
  Future<List<WorkEntry>> getWorkEntriesByWeek(DateTime weekStart);

  // Get the currently active work entry (if any)
  Future<WorkEntry?> getActiveWorkEntry();

  // Save a new work entry
  Future<void> saveWorkEntry(WorkEntry workEntry);

  // Update an existing work entry
  Future<void> updateWorkEntry(WorkEntry workEntry);

  // Delete a work entry
  Future<void> deleteWorkEntry(String id);

  // Get total hours worked for a specific week
  Future<double> getTotalHoursForWeek(DateTime weekStart);

  // Get task rating summary for a specific week
  Future<Map<String, int>> getTaskRatingSummaryForWeek(DateTime weekStart);

  // Get daily hours for a specific week (for charts)
  Future<Map<DateTime, double>> getDailyHoursForWeek(DateTime weekStart);
}
