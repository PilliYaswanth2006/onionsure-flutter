import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppTutorialDialog extends StatefulWidget {
  const AppTutorialDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AppTutorialDialog(),
    );
  }

  @override
  State<AppTutorialDialog> createState() => _AppTutorialDialogState();
}

class _AppTutorialDialogState extends State<AppTutorialDialog> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Welcome to OnionSure',
      'icon': Icons.spa_outlined,
      'summary':
          'OnionSure is an offline prototype demonstrating an AI-assisted field inspection workflow for onion grading. It uses prepared demonstration datasets rather than live AI inference.',
      'highlights': [
        'Designed for Smart India Hackathon (SIH26031)',
        '100% offline field operation without cloud dependencies',
        'Transparent decision rules and human inspector oversight',
      ],
    },
    {
      'title': 'Lot Registration',
      'icon': Icons.assignment_outlined,
      'summary':
          'Record the lot identification, producer/farmer details, procurement mandi, onion variety, and lot quantity before taking any samples.',
      'highlights': [
        'Auto-generated inspection identifier for traceability',
        'Standard produce details (e.g. Nashik Red, 500 kg)',
        'Assayer and mandi credentials logged for auditability',
      ],
    },
    {
      'title': 'Sample Selection',
      'icon': Icons.grid_view_outlined,
      'summary':
          'Select one or more prepared sample trays for evaluation. Individual sample quality classifications remain hidden until the Analysis stage to prevent confirmation bias.',
      'highlights': [
        'Choose any number of sample trays (1 to N)',
        'Neutral identifiers (S01 · Sample 01) preserve objectivity',
        'Tap any tray thumbnail to inspect the full-resolution image',
      ],
    },
    {
      'title': 'Smart Capture',
      'icon': Icons.camera_alt_outlined,
      'summary':
          'Review camera capture conditions and simulated readiness checks before confirming each selected sample for analysis.',
      'highlights': [
        'Follow vertical positioning and non-overlapping guidance',
        'Simulated checks verify lighting, blur, and reference target',
        'Explicit calibration disclosure for diameter estimation',
      ],
    },
    {
      'title': 'Analysis and Aggregation',
      'icon': Icons.analytics_outlined,
      'summary':
          'Inspect the prepared computer-vision observations for each sample, drill down into individual onion measurements, and combine all samples into lot-level quality counts.',
      'highlights': [
        'Categorized counts: Healthy, Surface Defect, Severe Visible Defect, Sprouting, Undersized',
        'Strict count-based aggregation (counts summed, percentages derived from combined total)',
        'Per-onion breakdown with estimated diameters and classification',
      ],
    },
    {
      'title': 'Grading Review',
      'icon': Icons.gavel_outlined,
      'summary':
          'The dynamic grading engine compares aggregated observations against configured tolerance limits. The inspector can record physical cut tests and confirm or override the outcome.',
      'highlights': [
        'Clear assessment: Grade A, URS, or Reject with exact limit breaches',
        'Mandatory physical internal cut test verification form',
        'Inspector audit actions: Confirm, Override (with reason), or Reject',
      ],
    },
    {
      'title': 'Report and QR Verification',
      'icon': Icons.qr_code_2_outlined,
      'summary':
          'Generate a comprehensive Digital Quality Report, export an official PDF document, and generate an offline QR verification passport for tamper-evident record lookup.',
      'highlights': [
        'Full photographic evidence gallery with raw and CV images',
        'High-contrast offline QR passport encoding inspection payload',
        'Local persistence with searchable inspection history archive',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final totalSteps = _steps.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Step counter & close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Step ${_currentStep + 1} of $totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.navyMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Step Title & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(step['icon'] as IconData,
                      size: 24, color: AppColors.tealPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Content Area (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['summary'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.navyText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Key Points:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...((step['highlights'] as List<String>).map((point) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppColors.tealPrimary,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.navyMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Progress bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / totalSteps,
              backgroundColor: AppColors.surfaceMuted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.tealPrimary),
              minHeight: 3,
            ),
            const SizedBox(height: 16),

            // Navigation Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 38),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Back'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Skip Tutorial',
                        style: TextStyle(color: AppColors.navyMuted)),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    minimumSize: const Size(0, 38),
                  ),
                  onPressed: () {
                    if (_currentStep < totalSteps - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                      _currentStep < totalSteps - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
