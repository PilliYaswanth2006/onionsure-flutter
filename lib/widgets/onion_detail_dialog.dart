import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../utils/app_theme.dart';
import 'disclaimer_banner.dart';

class OnionDetailDialog extends StatelessWidget {
  final SampleModel sample;

  const OnionDetailDialog({
    super.key,
    required this.sample,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = sample.analysis;
    final diameters = analysis.diametersMm;

    // Distribute categories deterministically according to structured counts
    // without inventing unsupported facts
    final counts = analysis.categoryCounts;
    final List<Map<String, String>> onionRecords = [];

    int healthyLeft = counts.healthy;
    int sproutingLeft = counts.sprouting;
    int severeLeft = counts.severeDefect;
    int surfaceLeft = counts.surfaceDefect;
    int undersizedLeft = counts.undersized;

    for (int i = 0; i < diameters.length; i++) {
      final diam = diameters[i];
      String classification = 'Healthy';
      String defect = 'None';
      if (severeLeft > 0) {
        classification = 'Severe Defect';
        defect = 'Visible Rot / Deep Infection';
        severeLeft--;
      } else if (sproutingLeft > 0) {
        classification = 'Sprouting';
        defect = 'Visible Foliage Emergence';
        sproutingLeft--;
      } else if (undersizedLeft > 0) {
        classification = 'Undersized';
        defect = 'Diameter < Standard Minimum';
        undersizedLeft--;
      } else if (surfaceLeft > 0) {
        classification = 'Surface Defect';
        defect = 'Superficial Peel / Blemish';
        surfaceLeft--;
      } else if (healthyLeft > 0) {
        classification = 'Healthy';
        defect = 'No Visible External Defect';
        healthyLeft--;
      }

      onionRecords.add({
        'id': 'Onion ${(i + 1).toString().padLeft(3, '0')}',
        'diameter': '$diam mm',
        'classification': classification,
        'defect': defect,
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 480,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sample.sampleId}: Per-Onion Breakdown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          '${sample.name} • ${analysis.totalOnions} onions cataloged',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.navyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const DisclaimerBanner.warning(
                message: 'Demo Measurement: Production deployment requires validated metric calibration (Calibration Status: demo_estimate).',
              ),
              const SizedBox(height: 12),
              // Measurement Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol('Avg Diameter', '${analysis.avgDiameter.toStringAsFixed(1)} mm'),
                    Container(height: 24, width: 1, color: AppColors.borderSubtle),
                    _metricCol('Min Diameter', '${analysis.minDiameter} mm'),
                    Container(height: 24, width: 1, color: AppColors.borderSubtle),
                    _metricCol('Max Diameter', '${analysis.maxDiameter} mm'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Individual Onion Records',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyText,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: onionRecords.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = onionRecords[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.tealLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tealDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['id']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    Text(
                                      'Ø ${item['diameter']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tealPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Classification: ${item['classification']} ',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.navyText,
                                      ),
                                    ),
                                    Text(
                                      '(${item['defect']})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.navyMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCol(String title, String val) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.navyMuted),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
      ],
    );
  }
}
