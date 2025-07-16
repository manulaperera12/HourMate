import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class WorkEntryLocalDataSource {
  Future<List<WorkEntryModel>> getAllWorkEntries();
  Future<void> saveWorkEntry(WorkEntryModel workEntry);
  Future<void> updateWorkEntry(WorkEntryModel workEntry);
  Future<void> deleteWorkEntry(String id);
}

class WorkEntryLocalDataSourceImpl implements WorkEntryLocalDataSource {
  final SharedPreferences sharedPreferences;

  WorkEntryLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<WorkEntryModel>> getAllWorkEntries() async {
    final String? workEntriesJson = sharedPreferences.getString(
      AppConstants.workEntriesKey,
    );

    if (workEntriesJson == null || workEntriesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(workEntriesJson);
      return jsonList
          .map((json) => WorkEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  @override
  Future<void> saveWorkEntry(WorkEntryModel workEntry) async {
    final List<WorkEntryModel> existingEntries = await getAllWorkEntries();
    existingEntries.add(workEntry);
    await _saveWorkEntries(existingEntries);
  }

  @override
  Future<void> updateWorkEntry(WorkEntryModel workEntry) async {
    final List<WorkEntryModel> existingEntries = await getAllWorkEntries();
    final int index = existingEntries.indexWhere(
      (entry) => entry.id == workEntry.id,
    );

    if (index != -1) {
      existingEntries[index] = workEntry;
      await _saveWorkEntries(existingEntries);
    }
  }

  @override
  Future<void> deleteWorkEntry(String id) async {
    final List<WorkEntryModel> existingEntries = await getAllWorkEntries();
    existingEntries.removeWhere((entry) => entry.id == id);
    await _saveWorkEntries(existingEntries);
  }

  Future<void> _saveWorkEntries(List<WorkEntryModel> workEntries) async {
    final List<Map<String, dynamic>> jsonList = workEntries
        .map((entry) => entry.toJson())
        .toList();

    final String workEntriesJson = json.encode(jsonList);
    await sharedPreferences.setString(
      AppConstants.workEntriesKey,
      workEntriesJson,
    );
  }
}
