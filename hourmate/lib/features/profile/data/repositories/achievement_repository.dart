import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_list.dart';

typedef AchievementMap = Map<String, dynamic>;

class AchievementRepository {
  static const String _achievementsKey = 'achievements';

  Future<List<Achievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_achievementsKey);
    final Map<String, Achievement> staticMap = {
      for (var a in AchievementList.all) a.key: a,
    };
    if (saved == null) {
      return AchievementList.all;
    }
    final List<Achievement> userAchievements = saved
        .map(
          (json) => Achievement.fromMap(
            Map<String, dynamic>.from(
              Map<String, dynamic>.from(Uri.splitQueryString(json)),
            ),
          ),
        )
        .toList();
    for (final userA in userAchievements) {
      if (staticMap.containsKey(userA.key)) {
        staticMap[userA.key] = staticMap[userA.key]!.copyWith(
          unlocked: userA.unlocked,
          progress: userA.progress,
        );
      }
    }
    return staticMap.values.toList();
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> toSave = achievements
        .map((a) => Uri(queryParameters: a.toMap()).query)
        .toList();
    await prefs.setStringList(_achievementsKey, toSave);
  }

  Future<void> updateAchievement(
    String key, {
    bool? unlocked,
    double? progress,
  }) async {
    final achievements = await loadAchievements();
    final idx = achievements.indexWhere((a) => a.key == key);
    if (idx != -1) {
      final updated = achievements[idx].copyWith(
        unlocked: unlocked ?? achievements[idx].unlocked,
        progress: progress ?? achievements[idx].progress,
      );
      achievements[idx] = updated;
      await saveAchievements(achievements);
    }
  }

  /// Static helper for global achievement updates
  static Future<void> updateAchievementGlobal(
    String key, {
    bool? unlocked,
    double? progress,
  }) async {
    final repo = AchievementRepository();
    await repo.updateAchievement(key, unlocked: unlocked, progress: progress);
  }
}
