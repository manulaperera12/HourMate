import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry_model.dart';

class WorkEntryLocalDataSource {
  static const String _workEntriesKey = 'work_entries';

  Future<List<WorkEntryModel>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_workEntriesKey) ?? [];
    final List<WorkEntryModel> validModels = [];
    for (final e in entriesJson) {
      if (e is String) {
        try {
          final model = WorkEntryModel.fromJson(e);
          if (model is WorkEntryModel) {
            validModels.add(model);
          }
        } catch (_) {
          // Skip corrupted entry
          continue;
        }
      }
    }
    return validModels;
  }

  /// Call this to clear corrupted work entry data (e.g., if error persists)
  static Future<void> clearCorruptedWorkEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.get(_workEntriesKey);
    if (entriesJson is! List<String>) {
      await prefs.remove(_workEntriesKey);
    }
  }

  Future<void> addEntry(WorkEntryModel entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllEntries();
    entries.add(entry);
    await prefs.setStringList(
      _workEntriesKey,
      entries.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> updateEntry(WorkEntryModel entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllEntries();
    final idx = entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      entries[idx] = entry;
      await prefs.setStringList(
        _workEntriesKey,
        entries.map((e) => e.toJson()).toList(),
      );
    }
  }

  Future<WorkEntryModel?> getActiveEntry() async {
    final entries = await getAllEntries();
    try {
      return entries.lastWhere((e) => e.endTime == null);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workEntriesKey);
  }

  // Alias for repository compatibility
  Future<List<WorkEntryModel>> getAllWorkEntries() async => getAllEntries();

  Future<void> saveWorkEntry(WorkEntryModel entry) async => addEntry(entry);

  Future<void> updateWorkEntry(WorkEntryModel entry) async =>
      updateEntry(entry);

  Future<void> deleteWorkEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllEntries();
    entries.removeWhere((e) => e.id == id);
    await prefs.setStringList(
      _workEntriesKey,
      entries.map((e) => e.toJson()).toList(),
    );
  }
}
