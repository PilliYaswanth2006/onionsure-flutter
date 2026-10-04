import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/progress_stepper.dart';
import 'ai_analysis_screen.dart';

class SmartCaptureScreen extends StatelessWidget {
  final InspectionRepository inspectionRepository;
  final String inspectionId;
  final String lotId;
  final String farmerName;
  final String procurementCentre;
  final String inspectorId;
  final String onionVariety;
  final String lotQuantity;
  final List<SampleModel> selectedSamples;
  final int currentSampleIndex;

  const SmartCaptureScreen({
    super.key,
    required this.inspectionRepository,
    required this.inspectionId,
    required this.lotId,
    required this.farmerName,
    required this.procurementCentre,
    required this.inspectorId,
    required this.onionVariety,
    required this.lotQuantity,
    required this.selectedSamples,
    required this.currentSampleIndex,
  });

  @override
  Widget build(BuildContext context) {
    final currentSample = selectedSamples[currentSampleIndex];
    final capture = currentSample.capture;
    final sampleNum = currentSampleIndex + 1;
    final totalSamples = selectedSamples.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Smart Capture ($sampleNum/$totalSamples)'),
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 3),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimers
                  const DisclaimerBanner.info(
                    message: 'Simulated field capture workflow using prepared demonstration images.',
                  ),
                  const SizedBox(height: 12),

                  // Image Viewport (Simulated Camera Frame)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.navyDark, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.asset(
                            currentSample.rawImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceMuted,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.broken_image, size: 40, color: AppColors.navyMuted),
                                    const SizedBox(height: 8),
                                    Text('Missing raw image: ${currentSample.rawImage}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Reticle Overlay / Viewfinder Guides
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        // Sample Tag
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${currentSample.sampleId}: ${currentSample.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Live calibration badge
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warningAmber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CALIB: DEMO ESTIMATE',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Capture Quality Indicators
                  const Text(
                    'Field Capture Quality Checks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildCheckRow(
                          'Image Quality',
                          capture.imageQuality.toUpperCase(),
                          true,
                          'Resolution acceptable for contour extraction',
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        _buildCheckRow(
                          'Lighting / Shadows',
                          'UNIFORM',
                          true,
                          'Diffused ambient daylight; no glare flares',
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        _buildCheckRow(
                          'Camera Angle / Blur',
                          'ORTHOGONAL',
                          true,
                          '90° vertical planar alignment; no motion blur',
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        _buildCheckRow(
                          'Reference Target Visible',
                          capture.referenceVisible ? 'VISIBLE' : 'NOT DETECTED',
                          capture.referenceVisible,
                          'Calibration scale card present in frame',
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        _buildCheckRow(
                          'Metric Calibration',
                          'DEMO ESTIMATE',
                          false,
                          'Status: ${capture.calibrationStatus} • Requires validated metric calibration',
                          isWarning: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AiAnalysisScreen(
                            inspectionRepository: inspectionRepository,
                            inspectionId: inspectionId,
                            lotId: lotId,
                            farmerName: farmerName,
                            procurementCentre: procurementCentre,
                            inspectorId: inspectorId,
                            onionVariety: onionVariety,
                            lotQuantity: lotQuantity,
                            selectedSamples: selectedSamples,
                            currentSampleIndex: currentSampleIndex,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology, size: 20),
                        const SizedBox(width: 8),
                        Text('Use This Sample ($sampleNum/$totalSamples)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Choose Another Sample'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(
    String label,
    String status,
    bool isPass,
    String detail, {
    bool isWarning = false,
  }) {
    Color iconColor = isPass ? AppColors.healthyGreen : AppColors.rejectRed;
    IconData icon = isPass ? Icons.check_circle : Icons.cancel;
    if (isWarning) {
      iconColor = AppColors.warningAmber;
      icon = Icons.warning_amber_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.navyMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
