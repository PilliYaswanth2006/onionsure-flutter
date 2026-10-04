import '../models/inspection_model.dart';
import '../models/sample_model.dart';

class AggregationService {
  /// Aggregates multiple samples by strictly summing raw COUNTS.
  /// Percentages are calculated from the aggregated counts, NEVER by averaging sample percentages.
  static AggregatedQualityResult aggregateSamples(List<SampleModel> samples) {
    if (samples.isEmpty) {
      return const AggregatedQualityResult(
        totalOnions: 0,
        totalHealthy: 0,
        totalSurfaceDefect: 0,
        totalSevereDefect: 0,
        totalSprouting: 0,
        totalUndersized: 0,
        avgDiameter: 0.0,
        minDiameter: 0,
        maxDiameter: 0,
        combinedDiameters: [],
      );
    }

    int totalOnions = 0;
    int totalHealthy = 0;
    int totalSurfaceDefect = 0;
    int totalSevereDefect = 0;
    int totalSprouting = 0;
    int totalUndersized = 0;
    final List<int> allDiameters = [];

    for (final sample in samples) {
      final counts = sample.analysis.categoryCounts;
      totalHealthy += counts.healthy;
      totalSurfaceDefect += counts.surfaceDefect;
      totalSevereDefect += counts.severeDefect;
      totalSprouting += counts.sprouting;
      totalUndersized += counts.undersized;

      totalOnions += sample.analysis.totalOnions;
      allDiameters.addAll(sample.analysis.diametersMm);
    }

    // Validation: aggregate category counts should equal aggregate total onions
    final calculatedCountSum = totalHealthy +
        totalSurfaceDefect +
        totalSevereDefect +
        totalSprouting +
        totalUndersized;

    // Handle invalid counts / zero totals / count mismatch gracefully without crashing
    if (totalOnions <= 0 || calculatedCountSum != totalOnions) {
      totalOnions = calculatedCountSum > 0 ? calculatedCountSum : totalOnions;
    }

    final double avgDiam = allDiameters.isNotEmpty
        ? allDiameters.reduce((a, b) => a + b) / allDiameters.length
        : 0.0;
    final int minDiam = allDiameters.isNotEmpty
        ? allDiameters.reduce((a, b) => a < b ? a : b)
        : 0;
    final int maxDiam = allDiameters.isNotEmpty
        ? allDiameters.reduce((a, b) => a > b ? a : b)
        : 0;

    return AggregatedQualityResult(
      totalOnions: totalOnions,
      totalHealthy: totalHealthy,
      totalSurfaceDefect: totalSurfaceDefect,
      totalSevereDefect: totalSevereDefect,
      totalSprouting: totalSprouting,
      totalUndersized: totalUndersized,
      avgDiameter: avgDiam,
      minDiameter: minDiam,
      maxDiameter: maxDiam,
      combinedDiameters: allDiameters,
    );
  }
}
