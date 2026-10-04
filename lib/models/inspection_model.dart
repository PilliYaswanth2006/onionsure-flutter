import 'grading_rule_model.dart';
import 'human_review_model.dart';

class AggregatedQualityResult {
  final int totalOnions;
  final int totalHealthy;
  final int totalSurfaceDefect;
  final int totalSevereDefect;
  final int totalSprouting;
  final int totalUndersized;

  final double avgDiameter;
  final int minDiameter;
  final int maxDiameter;
  final List<int> combinedDiameters;

  const AggregatedQualityResult({
    required this.totalOnions,
    required this.totalHealthy,
    required this.totalSurfaceDefect,
    required this.totalSevereDefect,
    required this.totalSprouting,
    required this.totalUndersized,
    required this.avgDiameter,
    required this.minDiameter,
    required this.maxDiameter,
    required this.combinedDiameters,
  });

  double get healthyPercent => totalOnions > 0 ? (totalHealthy / totalOnions) * 100 : 0.0;
  double get surfaceDefectPercent => totalOnions > 0 ? (totalSurfaceDefect / totalOnions) * 100 : 0.0;
  double get severeDefectPercent => totalOnions > 0 ? (totalSevereDefect / totalOnions) * 100 : 0.0;
  double get sproutingPercent => totalOnions > 0 ? (totalSprouting / totalOnions) * 100 : 0.0;
  double get undersizedPercent => totalOnions > 0 ? (totalUndersized / totalOnions) * 100 : 0.0;

  bool get isValid => (totalHealthy + totalSurfaceDefect + totalSevereDefect + totalSprouting + totalUndersized) == totalOnions;

  factory AggregatedQualityResult.fromJson(Map<String, dynamic> json) {
    final diams = (json['combined_diameters'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toInt())
        .toList();

    return AggregatedQualityResult(
      totalOnions: (json['total_onions'] as num?)?.toInt() ?? 0,
      totalHealthy: (json['total_healthy'] as num?)?.toInt() ?? 0,
      totalSurfaceDefect: (json['total_surface_defect'] as num?)?.toInt() ?? 0,
      totalSevereDefect: (json['total_severe_defect'] as num?)?.toInt() ?? 0,
      totalSprouting: (json['total_sprouting'] as num?)?.toInt() ?? 0,
      totalUndersized: (json['total_undersized'] as num?)?.toInt() ?? 0,
      avgDiameter: (json['avg_diameter'] as num?)?.toDouble() ?? 0.0,
      minDiameter: (json['min_diameter'] as num?)?.toInt() ?? 0,
      maxDiameter: (json['max_diameter'] as num?)?.toInt() ?? 0,
      combinedDiameters: diams,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_onions': totalOnions,
    'total_healthy': totalHealthy,
    'total_surface_defect': totalSurfaceDefect,
    'total_severe_defect': totalSevereDefect,
    'total_sprouting': totalSprouting,
    'total_undersized': totalUndersized,
    'avg_diameter': avgDiameter,
    'min_diameter': minDiameter,
    'max_diameter': maxDiameter,
    'combined_diameters': combinedDiameters,
  };
}

class InspectionModel {
  final String inspectionId;
  final String lotId;
  final String farmerName;
  final String procurementCentre;
  final String inspectorId;
  final String onionVariety;
  final String lotQuantity;
  final DateTime timestamp;

  final List<String> selectedSampleIds;
  final AggregatedQualityResult aggregatedResult;
  final DynamicGradingConfig rulesUsed; // Immutable snapshot of rules
  final String engineResult; // Grade A, URS, Reject, Review Required
  final List<String> engineExplanations;
  final String finalResult;
  final HumanReviewRecord? humanReview;
  final String syncStatus; // 'Pending Sync', 'Synced', 'Not Connected'

  const InspectionModel({
    required this.inspectionId,
    required this.lotId,
    required this.farmerName,
    required this.procurementCentre,
    required this.inspectorId,
    required this.onionVariety,
    required this.lotQuantity,
    required this.timestamp,
    required this.selectedSampleIds,
    required this.aggregatedResult,
    required this.rulesUsed,
    required this.engineResult,
    required this.engineExplanations,
    required this.finalResult,
    this.humanReview,
    this.syncStatus = 'Pending Sync',
  });

  InspectionModel copyWith({
    String? inspectionId,
    String? lotId,
    String? farmerName,
    String? procurementCentre,
    String? inspectorId,
    String? onionVariety,
    String? lotQuantity,
    DateTime? timestamp,
    List<String>? selectedSampleIds,
    AggregatedQualityResult? aggregatedResult,
    DynamicGradingConfig? rulesUsed,
    String? engineResult,
    List<String>? engineExplanations,
    String? finalResult,
    HumanReviewRecord? humanReview,
    String? syncStatus,
  }) {
    return InspectionModel(
      inspectionId: inspectionId ?? this.inspectionId,
      lotId: lotId ?? this.lotId,
      farmerName: farmerName ?? this.farmerName,
      procurementCentre: procurementCentre ?? this.procurementCentre,
      inspectorId: inspectorId ?? this.inspectorId,
      onionVariety: onionVariety ?? this.onionVariety,
      lotQuantity: lotQuantity ?? this.lotQuantity,
      timestamp: timestamp ?? this.timestamp,
      selectedSampleIds: selectedSampleIds ?? this.selectedSampleIds,
      aggregatedResult: aggregatedResult ?? this.aggregatedResult,
      rulesUsed: rulesUsed ?? this.rulesUsed,
      engineResult: engineResult ?? this.engineResult,
      engineExplanations: engineExplanations ?? this.engineExplanations,
      finalResult: finalResult ?? this.finalResult,
      humanReview: humanReview ?? this.humanReview,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      inspectionId: json['inspection_id'] as String? ?? '',
      lotId: json['lot_id'] as String? ?? '',
      farmerName: json['farmer_name'] as String? ?? '',
      procurementCentre: json['procurement_centre'] as String? ?? '',
      inspectorId: json['inspector_id'] as String? ?? '',
      onionVariety: json['onion_variety'] as String? ?? '',
      lotQuantity: json['lot_quantity'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      selectedSampleIds: (json['selected_sample_ids'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      aggregatedResult: AggregatedQualityResult.fromJson(
          json['aggregated_result'] as Map<String, dynamic>? ?? {}),
      rulesUsed: DynamicGradingConfig.fromJson(
          json['rules_used'] as Map<String, dynamic>? ?? {}),
      engineResult: json['engine_result'] as String? ?? 'Review Required',
      engineExplanations: (json['engine_explanations'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      finalResult: json['final_result'] as String? ?? 'Review Required',
      humanReview: json['human_review'] != null
          ? HumanReviewRecord.fromJson(
              json['human_review'] as Map<String, dynamic>)
          : null,
      syncStatus: json['sync_status'] as String? ?? 'Pending Sync',
    );
  }

  Map<String, dynamic> toJson() => {
    'inspection_id': inspectionId,
    'lot_id': lotId,
    'farmer_name': farmerName,
    'procurement_centre': procurementCentre,
    'inspector_id': inspectorId,
    'onion_variety': onionVariety,
    'lot_quantity': lotQuantity,
    'timestamp': timestamp.toIso8601String(),
    'selected_sample_ids': selectedSampleIds,
    'aggregated_result': aggregatedResult.toJson(),
    'rules_used': rulesUsed.toJson(),
    'engine_result': engineResult,
    'engine_explanations': engineExplanations,
    'final_result': finalResult,
    'human_review': humanReview?.toJson(),
    'sync_status': syncStatus,
  };
}
