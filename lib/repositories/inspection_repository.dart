import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inspection_model.dart';

class InspectionRepository {
  static const String _key = 'sih_inspection_history_v1';
  final List<InspectionModel> _inMemoryList = [];

  Future<List<InspectionModel>> getAllInspections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        _inMemoryList.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _inMemoryList.add(InspectionModel.fromJson(item));
          }
        }
      }
    } catch (_) {
      // In-memory fallback
    }

    // Return sorted newest first
    _inMemoryList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(_inMemoryList);
  }

  Future<InspectionModel?> getInspectionById(String inspectionId) async {
    final all = await getAllInspections();
    try {
      return all.firstWhere((i) => i.inspectionId == inspectionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveInspection(InspectionModel inspection) async {
    final all = await getAllInspections();
    final updated = List<InspectionModel>.from(all);
    final existingIndex = updated.indexWhere((i) => i.inspectionId == inspection.inspectionId);

    if (existingIndex >= 0) {
      updated[existingIndex] = inspection;
    } else {
      updated.insert(0, inspection);
    }

    _inMemoryList.clear();
    _inMemoryList.addAll(updated);

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = updated.map((i) => i.toJson()).toList();
      await prefs.setString(_key, json.encode(jsonList));
    } catch (_) {
      // Retained in-memory
    }
  }

  Future<void> clearAll() async {
    _inMemoryList.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // Retained in-memory
    }
  }
}
