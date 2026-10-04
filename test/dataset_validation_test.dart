import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Dataset Validation: All 10 verification checks on samples.json and assets',
      () async {
    final samplesFile = File('assets/data/samples.json');
    expect(await samplesFile.exists(), isTrue,
        reason: 'samples.json must exist');

    final jsonContent = await samplesFile.readAsString();
    final dynamic decoded = json.decode(jsonContent);
    expect(decoded, isA<Map<String, dynamic>>(),
        reason: 'samples.json must be a valid JSON object');

    final samples =
        (decoded as Map<String, dynamic>)['samples'] as List<dynamic>?;
    expect(samples, isNotNull);
    expect(samples!.length, greaterThanOrEqualTo(5),
        reason: 'At least 5 samples must be present');

    final sampleIds = <String>{};

    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i] as Map<String, dynamic>;
      final sid = sample['sample_id'] as String?;
      expect(sid, isNotNull, reason: 'sample_id must not be null');

      // Check unique sample IDs
      expect(sampleIds.contains(sid), isFalse,
          reason: 'Sample ID $sid must be unique');
      sampleIds.add(sid!);

      // Check paired raw and annotated image paths exist on disk
      final rawPath = sample['raw_image'] as String?;
      final annotedPath = sample['annotated_image'] as String?;
      expect(rawPath, isNotNull);
      expect(annotedPath, isNotNull);

      final rawFile = File(rawPath!);
      final annotedFile = File(annotedPath!);
      expect(await rawFile.exists(), isTrue,
          reason: 'Raw image must exist at $rawPath');
      expect(await annotedFile.exists(), isTrue,
          reason: 'Annotated image must exist at $annotedPath');

      // Check analysis and counts
      final analysis = sample['analysis'] as Map<String, dynamic>?;
      expect(analysis, isNotNull);

      final totalOnions = analysis!['total_onions'] as int?;
      expect(totalOnions, isNotNull);
      expect(totalOnions!, greaterThan(0),
          reason: 'total_onions must be positive');

      final categoryCounts =
          analysis['category_counts'] as Map<String, dynamic>?;
      expect(categoryCounts, isNotNull);

      int sumCounts = 0;
      categoryCounts!.forEach((key, val) {
        final count = (val as num).toInt();
        expect(count, greaterThanOrEqualTo(0),
            reason: 'Category $key in sample $sid cannot be negative');
        sumCounts += count;
      });

      // Verification: Category counts sum == total_onions
      expect(
        sumCounts,
        equals(totalOnions),
        reason:
            'Category count sum ($sumCounts) must equal total_onions ($totalOnions) in sample $sid',
      );

      // Verification: Diameter array length == total_onions when present
      final diameters = (analysis['diameters_mm'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList();
      if (diameters != null) {
        expect(
          diameters.length,
          equals(totalOnions),
          reason:
              'Diameter array length must equal total_onions in sample $sid',
        );
        for (final d in diameters) {
          expect(d, greaterThan(0),
              reason: 'Diameter value $d must be strictly positive');
        }
      }
    }
  });
}
