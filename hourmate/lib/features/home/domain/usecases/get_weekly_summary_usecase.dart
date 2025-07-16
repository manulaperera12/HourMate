import 'package:equatable/equatable.dart';
import '../repositories/work_entry_repository.dart';

class WeeklySummary {
  final double totalHours;
  final Map<String, int> taskRatingSummary;
  final Map<DateTime, double> dailyHours;

  const WeeklySummary({
    required this.totalHours,
    required this.taskRatingSummary,
    required this.dailyHours,
  });
}

class GetWeeklySummaryUseCase extends Equatable {
  final WorkEntryRepository repository;

  const GetWeeklySummaryUseCase({required this.repository});

  Future<WeeklySummary> call(DateTime weekStart) async {
    final double totalHours = await repository.getTotalHoursForWeek(weekStart);
    final Map<String, int> taskRatingSummary = await repository
        .getTaskRatingSummaryForWeek(weekStart);
    final Map<DateTime, double> dailyHours = await repository
        .getDailyHoursForWeek(weekStart);

    return WeeklySummary(
      totalHours: totalHours,
      taskRatingSummary: taskRatingSummary,
      dailyHours: dailyHours,
    );
  }

  @override
  List<Object?> get props => [repository];
}
