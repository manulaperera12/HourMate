import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../domain/entities/achievement.dart';

class AchievementsCubit extends Cubit<List<Achievement>> {
  AchievementsCubit() : super([]);

  Future<void> loadAchievements() async {
    final repo = AchievementRepository();
    emit(await repo.loadAchievements());
  }

  Future<void> updateAchievement(
    String key, {
    bool? unlocked,
    double? progress,
  }) async {
    await AchievementRepository.updateAchievementGlobal(
      key,
      unlocked: unlocked,
      progress: progress,
    );
    await loadAchievements();
  }
}

/// Usage example (from any widget or bloc):
///
///   context.read<AchievementsCubit>().updateAchievement(
///     'early_bird',
///     unlocked: true,
///     progress: 1.0,
///   );
