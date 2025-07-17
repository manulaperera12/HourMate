import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry_model.dart';

class WorkEntryLocalDataSource {
  static const String _workEntriesKey = 'work_entries';

  Future<List<WorkEntryModel>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_workEntriesKey) ?? [];
    return entriesJson.map((e) => WorkEntryModel.fromJson(e)).toList();
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
