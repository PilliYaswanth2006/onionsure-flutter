import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/sample_model.dart';

class DatasetService {
  List<SampleModel>? _cachedSamples;
  Map<String, dynamic>? _metadata;

  Map<String, dynamic>? get metadata => _metadata;

  Future<List<SampleModel>> loadSamples() async {
    if (_cachedSamples != null) {
      return _cachedSamples!;
    }

    String jsonString;
    try {
      final file = File('assets/data/samples.json');
      if (file.existsSync()) {
        jsonString = file.readAsStringSync();
      } else {
        jsonString = await rootBundle.loadString('assets/data/samples.json');
      }
    } catch (e) {
      jsonString = await rootBundle.loadString('assets/data/samples.json');
    }

    final dynamic parsed = json.decode(jsonString);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object in samples.json');
    }

    _metadata = {
      'dataset_version': parsed['dataset_version'],
      'dataset_name': parsed['dataset_name'],
      'problem_statement_id': parsed['problem_statement_id'],
      'project_title': parsed['project_title'],
      'description': parsed['description'],
      'data_provenance': parsed['data_provenance'],
      'category_definitions': parsed['category_definitions'],
    };

    final rawSamples = parsed['samples'] as List<dynamic>? ?? [];
    final samples = <SampleModel>[];

    for (final item in rawSamples) {
      if (item is Map<String, dynamic>) {
        samples.add(SampleModel.fromJson(item));
      }
    }

    _cachedSamples = samples;
    return samples;
  }

  Future<SampleModel?> getSampleById(String sampleId) async {
    final list = await loadSamples();
    try {
      return list.firstWhere((s) => s.sampleId == sampleId);
    } catch (_) {
      return null;
    }
  }

  void clearCache() {
    _cachedSamples = null;
    _metadata = null;
  }
}
