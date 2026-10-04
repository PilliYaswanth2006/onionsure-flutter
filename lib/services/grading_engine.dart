import '../models/grading_rule_model.dart';
import '../models/inspection_model.dart';

class GradingDecision {
  final String outcome; // 'Grade A', 'URS', 'Reject', 'Review Required'
  final List<String> observations;
  final List<String> ruleChecks;
  final List<String> explanations;
  final List<String> failureReasons;
  final bool requiresReview;
  final String? reviewReason;

  const GradingDecision({
    required this.outcome,
    required this.observations,
    required this.ruleChecks,
    required this.explanations,
    this.failureReasons = const [],
    required this.requiresReview,
    this.reviewReason,
  });
}

class GradingEngine {
  /// Evaluates aggregated observations against the active dynamic grading configuration.
  /// Generates explainable audit reasons for the outcome.
  static GradingDecision evaluate({
    required AggregatedQualityResult aggregated,
    required DynamicGradingConfig config,
  }) {
    final observations = <String>[];
    final ruleChecks = <String>[];
    final explanations = <String>[];

    final sproutingPct = aggregated.sproutingPercent;
    final severeDefectPct = aggregated.severeDefectPercent;
    final surfaceDefectPct = aggregated.surfaceDefectPercent;
    final undersizedPct = aggregated.undersizedPercent;
    final avgDiam = aggregated.avgDiameter;

    // 1. Record structured observations
    observations.add('Total Onions Analyzed: ${aggregated.totalOnions}');
    observations.add(
        'Healthy: ${aggregated.totalHealthy} (${aggregated.healthyPercent.toStringAsFixed(1)}%)');
    observations.add(
        'Surface Defects: ${aggregated.totalSurfaceDefect} (${surfaceDefectPct.toStringAsFixed(1)}%)');
    observations.add(
        'Severe Visible Defect: ${aggregated.totalSevereDefect} (${severeDefectPct.toStringAsFixed(1)}%)');
    observations.add(
        'Sprouting: ${aggregated.totalSprouting} (${sproutingPct.toStringAsFixed(1)}%)');
    observations.add(
        'Undersized: ${aggregated.totalUndersized} (${undersizedPct.toStringAsFixed(1)}%)');
    observations.add(
        'Diameter (Est.): Avg ${avgDiam.toStringAsFixed(1)}mm (Range ${aggregated.minDiameter}-${aggregated.maxDiameter}mm)');

    // 2. Check Grade A tolerances
    bool passesGradeA = true;
    final gradeAFailures = <String>[];

    if (sproutingPct > config.sproutingGradeAMax) {
      passesGradeA = false;
      gradeAFailures.add(
        'Sprouting: ${sproutingPct.toStringAsFixed(1)}% > ${config.sproutingGradeAMax}%',
      );
    }
    if (severeDefectPct > config.rotGradeAMax) {
      passesGradeA = false;
      gradeAFailures.add(
        'Severe Visible Defect: ${severeDefectPct.toStringAsFixed(1)}% > ${config.rotGradeAMax}%',
      );
    }
    if (surfaceDefectPct > config.surfaceDefectGradeAMax) {
      passesGradeA = false;
      gradeAFailures.add(
        'Surface Defect: ${surfaceDefectPct.toStringAsFixed(1)}% > ${config.surfaceDefectGradeAMax}%',
      );
    }
    if (undersizedPct > config.undersizedGradeAMax) {
      passesGradeA = false;
      gradeAFailures.add(
        'Undersized: ${undersizedPct.toStringAsFixed(1)}% > ${config.undersizedGradeAMax}%',
      );
    }
    if (avgDiam < config.diameterMinMm || avgDiam > config.diameterMaxMm) {
      passesGradeA = false;
      gradeAFailures.add(
        'Average Diameter: ${avgDiam.toStringAsFixed(1)}mm outside ${config.diameterMinMm}-${config.diameterMaxMm}mm',
      );
    }

    // 3. Check URS (Under-Relaxed Specification) tolerances
    bool passesUrs = true;
    final ursFailures = <String>[];

    if (sproutingPct > config.sproutingUrsMax) {
      passesUrs = false;
      ursFailures.add(
        'Sprouting: ${sproutingPct.toStringAsFixed(1)}% > ${config.sproutingUrsMax}%',
      );
    }
    if (severeDefectPct > config.rotUrsMax) {
      passesUrs = false;
      ursFailures.add(
        'Severe Visible Defect: ${severeDefectPct.toStringAsFixed(1)}% > ${config.rotUrsMax}%',
      );
    }
    if (surfaceDefectPct > config.surfaceDefectUrsMax) {
      passesUrs = false;
      ursFailures.add(
        'Surface Defect: ${surfaceDefectPct.toStringAsFixed(1)}% > ${config.surfaceDefectUrsMax}%',
      );
    }
    if (undersizedPct > config.undersizedUrsMax) {
      passesUrs = false;
      ursFailures.add(
        'Undersized: ${undersizedPct.toStringAsFixed(1)}% > ${config.undersizedUrsMax}%',
      );
    }

    // 4. Determine Outcome & Review Flags
    String outcome;
    bool requiresReview = false;
    String? reviewReason;
    List<String> applicableFailures = [];

    if (passesGradeA) {
      outcome = 'Grade A';
      explanations.add(
          'Lot satisfies all configured Grade A quality and diameter tolerances.');
      ruleChecks.add('✓ Sprouting: Within Grade A limit');
      ruleChecks.add('✓ Severe Visible Defect: Within Grade A limit');
      ruleChecks.add('✓ Surface Defects: Within Grade A limit');
      ruleChecks.add('✓ Diameter Range: Compliant');
    } else if (passesUrs) {
      applicableFailures = List.unmodifiable(gradeAFailures);
      // If borderline or severe defects exist in URS, flag for Human Review
      if (severeDefectPct > 0 ||
          sproutingPct >= (config.sproutingUrsMax - 1.0)) {
        outcome = 'Review Required';
        requiresReview = true;
        reviewReason = severeDefectPct > 0
            ? 'Severe visible defect observed (${severeDefectPct.toStringAsFixed(1)}%). Requires inspector physical confirmation.'
            : 'Sprouting near upper threshold (${sproutingPct.toStringAsFixed(1)}%). Inspector review required.';
        explanations.addAll(gradeAFailures);
        explanations.add(
            'Lot qualifies for URS specifications pending human inspector verification.');
      } else {
        outcome = 'URS';
        explanations.addAll(gradeAFailures);
        explanations.add(
            'Lot does not meet Grade A criteria, but complies with Under-Relaxed Specifications (URS).');
      }

      ruleChecks.add(
          '✗ Grade A: Exceeded tolerances (${gradeAFailures.length} criteria)');
      ruleChecks.add('✓ URS: Within acceptable relaxed boundaries');
    } else {
      outcome = 'Reject';
      applicableFailures = List.unmodifiable(ursFailures);
      requiresReview = true;
      reviewReason =
          'Lot exceeded maximum allowable tolerances for commercial procurement: ${ursFailures.join("; ")}';
      explanations.addAll(ursFailures);
      ruleChecks.add('✗ Grade A: Failed');
      ruleChecks.add('✗ URS: Failed (${ursFailures.join("; ")})');
    }

    return GradingDecision(
      outcome: outcome,
      observations: observations,
      ruleChecks: ruleChecks,
      explanations: explanations,
      failureReasons: applicableFailures,
      requiresReview: requiresReview,
      reviewReason: reviewReason,
    );
  }
}
