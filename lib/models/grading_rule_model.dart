class DynamicGradingConfig {
  final int diameterMinMm;
  final int diameterMaxMm;
  final double sproutingGradeAMax;
  final double rotGradeAMax;
  final double surfaceDefectGradeAMax;
  final double undersizedGradeAMax;

  final double sproutingUrsMax;
  final double rotUrsMax;
  final double surfaceDefectUrsMax;
  final double undersizedUrsMax;

  const DynamicGradingConfig({
    required this.diameterMinMm,
    required this.diameterMaxMm,
    required this.sproutingGradeAMax,
    required this.rotGradeAMax,
    required this.surfaceDefectGradeAMax,
    required this.undersizedGradeAMax,
    required this.sproutingUrsMax,
    required this.rotUrsMax,
    required this.surfaceDefectUrsMax,
    required this.undersizedUrsMax,
  });

  static const DynamicGradingConfig defaultNashikRed = DynamicGradingConfig(
    diameterMinMm: 35,
    diameterMaxMm: 70,
    sproutingGradeAMax: 0.0,
    rotGradeAMax: 0.0,
    surfaceDefectGradeAMax: 5.0,
    undersizedGradeAMax: 5.0,
    sproutingUrsMax: 5.0,
    rotUrsMax: 3.0,
    surfaceDefectUrsMax: 15.0,
    undersizedUrsMax: 10.0,
  );

  DynamicGradingConfig copyWith({
    int? diameterMinMm,
    int? diameterMaxMm,
    double? sproutingGradeAMax,
    double? rotGradeAMax,
    double? surfaceDefectGradeAMax,
    double? undersizedGradeAMax,
    double? sproutingUrsMax,
    double? rotUrsMax,
    double? surfaceDefectUrsMax,
    double? undersizedUrsMax,
  }) {
    return DynamicGradingConfig(
      diameterMinMm: diameterMinMm ?? this.diameterMinMm,
      diameterMaxMm: diameterMaxMm ?? this.diameterMaxMm,
      sproutingGradeAMax: sproutingGradeAMax ?? this.sproutingGradeAMax,
      rotGradeAMax: rotGradeAMax ?? this.rotGradeAMax,
      surfaceDefectGradeAMax:
          surfaceDefectGradeAMax ?? this.surfaceDefectGradeAMax,
      undersizedGradeAMax: undersizedGradeAMax ?? this.undersizedGradeAMax,
      sproutingUrsMax: sproutingUrsMax ?? this.sproutingUrsMax,
      rotUrsMax: rotUrsMax ?? this.rotUrsMax,
      surfaceDefectUrsMax: surfaceDefectUrsMax ?? this.surfaceDefectUrsMax,
      undersizedUrsMax: undersizedUrsMax ?? this.undersizedUrsMax,
    );
  }

  factory DynamicGradingConfig.fromJson(Map<String, dynamic> json) {
    return DynamicGradingConfig(
      diameterMinMm: (json['diameter_min_mm'] as num?)?.toInt() ?? 35,
      diameterMaxMm: (json['diameter_max_mm'] as num?)?.toInt() ?? 70,
      sproutingGradeAMax:
          (json['sprouting_grade_a_max'] as num?)?.toDouble() ?? 0.0,
      rotGradeAMax: (json['rot_grade_a_max'] as num?)?.toDouble() ?? 0.0,
      surfaceDefectGradeAMax:
          (json['surface_defect_grade_a_max'] as num?)?.toDouble() ?? 5.0,
      undersizedGradeAMax:
          (json['undersized_grade_a_max'] as num?)?.toDouble() ?? 5.0,
      sproutingUrsMax: (json['sprouting_urs_max'] as num?)?.toDouble() ?? 5.0,
      rotUrsMax: (json['rot_urs_max'] as num?)?.toDouble() ?? 3.0,
      surfaceDefectUrsMax:
          (json['surface_defect_urs_max'] as num?)?.toDouble() ?? 15.0,
      undersizedUrsMax:
          (json['undersized_urs_max'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'diameter_min_mm': diameterMinMm,
        'diameter_max_mm': diameterMaxMm,
        'sprouting_grade_a_max': sproutingGradeAMax,
        'rot_grade_a_max': rotGradeAMax,
        'surface_defect_grade_a_max': surfaceDefectGradeAMax,
        'undersized_grade_a_max': undersizedGradeAMax,
        'sprouting_urs_max': sproutingUrsMax,
        'rot_urs_max': rotUrsMax,
        'surface_defect_urs_max': surfaceDefectUrsMax,
        'undersized_urs_max': undersizedUrsMax,
      };
}
