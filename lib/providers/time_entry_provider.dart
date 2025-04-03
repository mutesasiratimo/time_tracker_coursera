import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  Box<TimeEntry>? _timeEntries;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _timeEntries = await Hive.openBox<TimeEntry>('time_entries');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TimeEntryProvider: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  List<TimeEntry> get entries {
    if (!_isInitialized || _timeEntries == null) {
      return [];
    }
    return _timeEntries!.values.toList();
  }

  Future<void> addEntry(TimeEntry entry) async {
    if (!_isInitialized || _timeEntries == null) {
      throw Exception('TimeEntryProvider not initialized');
    }
    await _timeEntries!.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    if (!_isInitialized || _timeEntries == null) {
      throw Exception('TimeEntryProvider not initialized');
    }
    await _timeEntries!.delete(id);
    notifyListeners();
  }

  List<TimeEntry> getEntriesByProject(String projectId) {
    if (!_isInitialized || _timeEntries == null) {
      return [];
    }
    return entries.where((entry) => entry.projectId == projectId).toList();
  }

  Future<void> close() async {
    if (_timeEntries != null && _timeEntries!.isOpen) {
      await _timeEntries!.close();
    }
    _isInitialized = false;
  }
}
