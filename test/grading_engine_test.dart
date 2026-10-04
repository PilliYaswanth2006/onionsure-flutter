import 'package:flutter_test/flutter_test.dart';
import 'package:sih_onion_grading/models/grading_rule_model.dart';
import 'package:sih_onion_grading/models/inspection_model.dart';
import 'package:sih_onion_grading/services/grading_engine.dart';

void main() {
  group('GradingEngine Tests', () {
    test('Grade A Qualification for Clean Batch', () {
      const cleanAgg = AggregatedQualityResult(
        totalOnions: 50,
        totalHealthy: 48,
        totalSurfaceDefect: 2,
        totalSevereDefect: 0,
        totalSprouting: 0,
        totalUndersized: 0,
        avgDiameter: 52.0,
        minDiameter: 45,
        maxDiameter: 60,
        combinedDiameters: [45, 52, 60],
      );

      final decision = GradingEngine.evaluate(
        aggregated: cleanAgg,
        config: DynamicGradingConfig.defaultNashikRed,
      );

      expect(decision.outcome, equals('Grade A'));
      expect(decision.requiresReview, isFalse);
      expect(
          decision.ruleChecks.any((c) => c.contains('Grade A limit')), isTrue);
    });

    test('Trigger Review Required for Severe Defect / Rot', () {
      const rotAgg = AggregatedQualityResult(
        totalOnions: 50,
        totalHealthy: 45,
        totalSurfaceDefect: 3,
        totalSevereDefect: 2, // 4.0% severe defect (rot)
        totalSprouting: 0,
        totalUndersized: 0,
        avgDiameter: 50.0,
        minDiameter: 42,
        maxDiameter: 58,
        combinedDiameters: [42, 50, 58],
      );

      final decision = GradingEngine.evaluate(
        aggregated: rotAgg,
        config: DynamicGradingConfig.defaultNashikRed,
      );

      expect(decision.requiresReview, isTrue);
      expect(decision.reviewReason, isNotNull);
      expect(decision.failureReasons,
          contains('Severe Visible Defect: 4.0% > 3.0%'));
    });

    test('Rejection when Exceeding URS Tolerances', () {
      const excessSproutingAgg = AggregatedQualityResult(
        totalOnions: 50,
        totalHealthy: 30,
        totalSurfaceDefect: 5,
        totalSevereDefect: 0,
        totalSprouting: 15, // 30% sprouting! Exceeds URS max (5%)
        totalUndersized: 0,
        avgDiameter: 48.0,
        minDiameter: 38,
        maxDiameter: 56,
        combinedDiameters: [38, 48, 56],
      );

      final decision = GradingEngine.evaluate(
        aggregated: excessSproutingAgg,
        config: DynamicGradingConfig.defaultNashikRed,
      );

      expect(decision.outcome, equals('Reject'));
      expect(decision.requiresReview, isTrue);
      expect(decision.failureReasons, contains('Sprouting: 30.0% > 5.0%'));
    });
  });
}
