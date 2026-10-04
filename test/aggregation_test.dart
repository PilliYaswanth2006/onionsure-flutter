import 'package:flutter_test/flutter_test.dart';
import 'package:sih_onion_grading/models/sample_model.dart';
import 'package:sih_onion_grading/services/aggregation_service.dart';

void main() {
  group('AggregationService Tests', () {
    test('Strict Count-based Multi-sample Aggregation (S01 + S03 + S04)', () {
      const s01 = SampleModel(
        sampleId: 'S01',
        name: 'Healthy Sample',
        description: 'Sample 1',
        rawImage: 'assets/images/raw/healthy.png',
        annotatedImage: 'assets/images/annoted/healthy.png',
        capture: CaptureInfo(
            status: 'accepted',
            imageQuality: 'good',
            referenceVisible: true,
            calibrationStatus: 'demo_estimate'),
        analysis: AnalysisInfo(
          status: 'precomputed_demo_result',
          totalOnions: 26,
          categoryCounts: CategoryCounts(
              healthy: 17,
              surfaceDefect: 7,
              severeDefect: 2,
              sprouting: 0,
              undersized: 0),
          diametersMm: [50, 52, 54],
          measurementStatus: 'demo_estimate',
        ),
      );

      const s03 = SampleModel(
        sampleId: 'S03',
        name: 'Sprouting Sample',
        description: 'Sample 3',
        rawImage: 'assets/images/raw/sprouting.png',
        annotatedImage: 'assets/images/annoted/sprouting.png',
        capture: CaptureInfo(
            status: 'accepted',
            imageQuality: 'good',
            referenceVisible: true,
            calibrationStatus: 'demo_estimate'),
        analysis: AnalysisInfo(
          status: 'precomputed_demo_result',
          totalOnions: 26,
          categoryCounts: CategoryCounts(
              healthy: 14,
              surfaceDefect: 0,
              severeDefect: 0,
              sprouting: 6,
              undersized: 6),
          diametersMm: [40, 42, 45],
          measurementStatus: 'demo_estimate',
        ),
      );

      const s04 = SampleModel(
        sampleId: 'S04',
        name: 'Surface Defect Sample',
        description: 'Sample 4',
        rawImage: 'assets/images/raw/surface_defects.png',
        annotatedImage: 'assets/images/annoted/surface_defects.png',
        capture: CaptureInfo(
            status: 'accepted',
            imageQuality: 'good',
            referenceVisible: true,
            calibrationStatus: 'demo_estimate'),
        analysis: AnalysisInfo(
          status: 'precomputed_demo_result',
          totalOnions: 26,
          categoryCounts: CategoryCounts(
              healthy: 13,
              surfaceDefect: 7,
              severeDefect: 1,
              sprouting: 0,
              undersized: 5),
          diametersMm: [46, 48, 50],
          measurementStatus: 'demo_estimate',
        ),
      );

      final result = AggregationService.aggregateSamples([s01, s03, s04]);

      // Check sum of total onions
      expect(result.totalOnions, equals(78));

      // Check individual category counts
      expect(result.totalHealthy, equals(44));
      expect(result.totalSurfaceDefect, equals(14));
      expect(result.totalSevereDefect, equals(3));
      expect(result.totalSprouting, equals(6));
      expect(result.totalUndersized, equals(11));

      // Check validation: aggregate category counts equal aggregate total onions
      expect(result.isValid, isTrue);

      // Check percentage derivations
      expect(result.healthyPercent, closeTo(56.41, 0.05));
      expect(result.surfaceDefectPercent, closeTo(17.95, 0.05));
      expect(result.severeDefectPercent, closeTo(3.85, 0.05));
      expect(result.sproutingPercent, closeTo(7.69, 0.05));
      expect(result.undersizedPercent, closeTo(14.10, 0.05));

      // Check combined diameters
      expect(result.combinedDiameters.length, equals(9));
      expect(result.minDiameter, equals(40));
      expect(result.maxDiameter, equals(54));
    });
  });
}
