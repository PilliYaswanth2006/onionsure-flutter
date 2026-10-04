import 'dart:convert';
import '../models/inspection_model.dart';

class QrVerificationData {
  final String inspectionId;
  final String lotId;
  final String farmer;
  final String centre;
  final String date;
  final int sampleCount;
  final int totalOnions;
  final String finalAssessment;
  final String verificationHash;

  const QrVerificationData({
    required this.inspectionId,
    required this.lotId,
    required this.farmer,
    required this.centre,
    required this.date,
    required this.sampleCount,
    required this.totalOnions,
    required this.finalAssessment,
    required this.verificationHash,
  });

  Map<String, dynamic> toJson() => {
    'insp': inspectionId,
    'lot': lotId,
    'farmer': farmer,
    'centre': centre,
    'date': date,
    'samples': sampleCount,
    'onions': totalOnions,
    'grade': finalAssessment,
    'hash': verificationHash,
  };

  factory QrVerificationData.fromJson(Map<String, dynamic> json) {
    return QrVerificationData(
      inspectionId: json['insp'] as String? ?? 'UNKNOWN',
      lotId: json['lot'] as String? ?? 'UNKNOWN',
      farmer: json['farmer'] as String? ?? 'N/A',
      centre: json['centre'] as String? ?? 'N/A',
      date: json['date'] as String? ?? '',
      sampleCount: (json['samples'] as num?)?.toInt() ?? 0,
      totalOnions: (json['onions'] as num?)?.toInt() ?? 0,
      finalAssessment: json['grade'] as String? ?? 'UNKNOWN',
      verificationHash: json['hash'] as String? ?? '',
    );
  }
}

class QrService {
  /// Encodes inspection data into a compact JSON verification payload.
  /// Note: The QR code serves as an offline access and lookup mechanism,
  /// not a cryptographic tamper-proof guarantee.
  static String generateVerificationPayload(InspectionModel inspection) {
    final dateStr = inspection.timestamp.toIso8601String().substring(0, 10);
    // Simple deterministic hash representation of the report
    final rawHashSource = '${inspection.inspectionId}:${inspection.lotId}:${inspection.finalResult}:${inspection.aggregatedResult.totalOnions}';
    final simpleHash = 'HASH-${rawHashSource.hashCode.toRadixString(16).toUpperCase()}';

    final data = QrVerificationData(
      inspectionId: inspection.inspectionId,
      lotId: inspection.lotId,
      farmer: inspection.farmerName,
      centre: inspection.procurementCentre,
      date: dateStr,
      sampleCount: inspection.selectedSampleIds.length,
      totalOnions: inspection.aggregatedResult.totalOnions,
      finalAssessment: inspection.finalResult,
      verificationHash: simpleHash,
    );

    return json.encode(data.toJson());
  }

  static QrVerificationData? parsePayload(String raw) {
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return QrVerificationData.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
