class HumanReviewRecord {
  final String originalResult;
  final String finalResult;
  final String action; // 'accepted', 'corrected', 'rejected'
  final String? reason;
  final String inspectorId;
  final DateTime timestamp;
  final bool internalVerificationPerformed;
  final String internalVerificationResult;
  final String? internalVerificationNotes;

  const HumanReviewRecord({
    required this.originalResult,
    required this.finalResult,
    required this.action,
    this.reason,
    required this.inspectorId,
    required this.timestamp,
    this.internalVerificationPerformed = false,
    this.internalVerificationResult = 'Not Performed',
    this.internalVerificationNotes,
  });

  factory HumanReviewRecord.fromJson(Map<String, dynamic> json) {
    return HumanReviewRecord(
      originalResult: json['original_result'] as String? ?? 'Review Required',
      finalResult: json['final_result'] as String? ?? 'Review Required',
      action: json['action'] as String? ?? 'accepted',
      reason: json['reason'] as String?,
      inspectorId: json['inspector_id'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      internalVerificationPerformed: json['internal_verification_performed'] as bool? ?? false,
      internalVerificationResult: json['internal_verification_result'] as String? ?? 'Not Performed',
      internalVerificationNotes: json['internal_verification_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'original_result': originalResult,
    'final_result': finalResult,
    'action': action,
    'reason': reason,
    'inspector_id': inspectorId,
    'timestamp': timestamp.toIso8601String(),
    'internal_verification_performed': internalVerificationPerformed,
    'internal_verification_result': internalVerificationResult,
    'internal_verification_notes': internalVerificationNotes,
  };
}
