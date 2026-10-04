import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grading_rule_model.dart';

class ConfigRepository {
  static const String _key = 'sih_dynamic_grading_config';
  DynamicGradingConfig _inMemoryConfig = DynamicGradingConfig.defaultNashikRed;

  Future<DynamicGradingConfig> getConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final map = json.decode(raw) as Map<String, dynamic>;
        _inMemoryConfig = DynamicGradingConfig.fromJson(map);
      }
    } catch (_) {
      // In tests or if SharedPreferences is uninitialized, fall back to in-memory
    }
    return _inMemoryConfig;
  }

  Future<void> saveConfig(DynamicGradingConfig config) async {
    _inMemoryConfig = config;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(config.toJson()));
    } catch (_) {
      // Retain in-memory
    }
  }

  Future<void> resetToDefaults() async {
    _inMemoryConfig = DynamicGradingConfig.defaultNashikRed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // Retain in-memory
    }
  }
}
