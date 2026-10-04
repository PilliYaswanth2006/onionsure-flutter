class CategoryCounts {
  final int healthy;
  final int surfaceDefect;
  final int severeDefect;
  final int sprouting;
  final int undersized;

  const CategoryCounts({
    required this.healthy,
    required this.surfaceDefect,
    required this.severeDefect,
    required this.sprouting,
    required this.undersized,
  });

  int get total => healthy + surfaceDefect + severeDefect + sprouting + undersized;

  double healthyPercent(int total) => total > 0 ? (healthy / total) * 100 : 0.0;
  double surfaceDefectPercent(int total) => total > 0 ? (surfaceDefect / total) * 100 : 0.0;
  double severeDefectPercent(int total) => total > 0 ? (severeDefect / total) * 100 : 0.0;
  double sproutingPercent(int total) => total > 0 ? (sprouting / total) * 100 : 0.0;
  double undersizedPercent(int total) => total > 0 ? (undersized / total) * 100 : 0.0;

  factory CategoryCounts.fromJson(Map<String, dynamic> json) {
    return CategoryCounts(
      healthy: (json['healthy'] as num?)?.toInt() ?? 0,
      surfaceDefect: (json['surface_defect'] as num?)?.toInt() ?? 0,
      severeDefect: (json['severe_defect'] as num?)?.toInt() ?? 0,
      sprouting: (json['sprouting'] as num?)?.toInt() ?? 0,
      undersized: (json['undersized'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'healthy': healthy,
    'surface_defect': surfaceDefect,
    'severe_defect': severeDefect,
    'sprouting': sprouting,
    'undersized': undersized,
  };
}

class CaptureInfo {
  final String status;
  final String imageQuality;
  final bool referenceVisible;
  final String calibrationStatus;

  const CaptureInfo({
    required this.status,
    required this.imageQuality,
    required this.referenceVisible,
    required this.calibrationStatus,
  });

  factory CaptureInfo.fromJson(Map<String, dynamic> json) {
    return CaptureInfo(
      status: json['status'] as String? ?? 'accepted',
      imageQuality: json['image_quality'] as String? ?? 'good',
      referenceVisible: json['reference_visible'] as bool? ?? true,
      calibrationStatus: json['calibration_status'] as String? ?? 'demo_estimate',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'image_quality': imageQuality,
    'reference_visible': referenceVisible,
    'calibration_status': calibrationStatus,
  };
}

class AnalysisInfo {
  final String status;
  final int totalOnions;
  final CategoryCounts categoryCounts;
  final List<int> diametersMm;
  final String measurementStatus;

  const AnalysisInfo({
    required this.status,
    required this.totalOnions,
    required this.categoryCounts,
    required this.diametersMm,
    required this.measurementStatus,
  });

  double get avgDiameter {
    if (diametersMm.isEmpty) return 0.0;
    return diametersMm.reduce((a, b) => a + b) / diametersMm.length;
  }

  int get minDiameter {
    if (diametersMm.isEmpty) return 0;
    return diametersMm.reduce((a, b) => a < b ? a : b);
  }

  int get maxDiameter {
    if (diametersMm.isEmpty) return 0;
    return diametersMm.reduce((a, b) => a > b ? a : b);
  }

  factory AnalysisInfo.fromJson(Map<String, dynamic> json) {
    final diametersRaw = json['diameters_mm'] as List<dynamic>? ?? [];
    final diameters = diametersRaw.map((e) => (e as num).toInt()).toList();

    return AnalysisInfo(
      status: json['status'] as String? ?? 'precomputed_demo_result',
      totalOnions: (json['total_onions'] as num?)?.toInt() ?? diameters.length,
      categoryCounts: CategoryCounts.fromJson(json['category_counts'] as Map<String, dynamic>? ?? {}),
      diametersMm: diameters,
      measurementStatus: json['measurement_status'] as String? ?? 'demo_estimate',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'total_onions': totalOnions,
    'category_counts': categoryCounts.toJson(),
    'diameters_mm': diametersMm,
    'measurement_status': measurementStatus,
  };
}

class SampleModel {
  final String sampleId;
  final String name;
  final String description;
  final String rawImage;
  final String annotatedImage;
  final CaptureInfo capture;
  final AnalysisInfo analysis;

  const SampleModel({
    required this.sampleId,
    required this.name,
    required this.description,
    required this.rawImage,
    required this.annotatedImage,
    required this.capture,
    required this.analysis,
  });

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    return SampleModel(
      sampleId: json['sample_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rawImage: json['raw_image'] as String? ?? '',
      annotatedImage: json['annotated_image'] as String? ?? '',
      capture: CaptureInfo.fromJson(json['capture'] as Map<String, dynamic>? ?? {}),
      analysis: AnalysisInfo.fromJson(json['analysis'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'sample_id': sampleId,
    'name': name,
    'description': description,
    'raw_image': rawImage,
    'annotated_image': annotatedImage,
    'capture': capture.toJson(),
    'analysis': analysis.toJson(),
  };
}
