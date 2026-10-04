import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/progress_stepper.dart';
import 'ai_analysis_screen.dart';

class SmartCaptureScreen extends StatefulWidget {
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
  State<SmartCaptureScreen> createState() => _SmartCaptureScreenState();
}

class _SmartCaptureScreenState extends State<SmartCaptureScreen> {
  late SampleModel _currentSample;

  @override
  void initState() {
    super.initState();
    _currentSample = widget.selectedSamples[widget.currentSampleIndex];
  }

  String _neutralTitle(SampleModel s) {
    final numStr = s.sampleId.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNum =
        numStr.isNotEmpty ? numStr.padLeft(2, '0') : s.sampleId;
    return '${s.sampleId} · Sample $formattedNum';
  }

  void _useDemoCapture() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Using prepared demo capture for ${_neutralTitle(_currentSample)} (Offline Demo).',
        ),
        backgroundColor: AppColors.tealDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capture = _currentSample.capture;
    final sampleNum = widget.currentSampleIndex + 1;
    final totalSamples = widget.selectedSamples.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Smart Capture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'Sample $sampleNum of $totalSamples',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.navyMuted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceMuted,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3 of 5 · Smart Capture',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Prepare and verify each selected sample before analysis.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.navyMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimers
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.tealPrimary.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.tealDark),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'DEMO CAPTURE: Simulated field capture workflow using prepared demonstration images.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.tealDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Capture Controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            side: const BorderSide(color: AppColors.tealPrimary),
                          ),
                          onPressed: _useDemoCapture,
                          icon: const Icon(Icons.camera_alt_outlined,
                              size: 18, color: AppColors.tealPrimary),
                          label: const Text(
                            'Use Demo Capture',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            side: const BorderSide(color: AppColors.navyMuted),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.photo_library_outlined,
                              size: 18, color: AppColors.navyDark),
                          label: const Text(
                            'Choose Demo Sample',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Capture Guidance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: AppColors.tealDark),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Capture Guidance',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _guidanceBullet(
                            'Arrange onions separately without overlap.'),
                        _guidanceBullet('Use consistent lighting.'),
                        _guidanceBullet(
                            'Position the camera as vertically as practical.'),
                        _guidanceBullet(
                            'Keep the tray/reference marker visible.'),
                        _guidanceBullet('Avoid blur and glare.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Image Viewport (Simulated Camera Frame - BoxFit.contain and tap-to-enlarge)
                  GestureDetector(
                    onTap: () {
                      ImageViewerDialog.show(
                        context,
                        imagePath: _currentSample.rawImage,
                        title:
                            '${_neutralTitle(_currentSample)} ($sampleNum of $totalSamples)',
                        subtitle: 'Tap anywhere to zoom/pan',
                      );
                    },
                    child: Container(
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
                              _currentSample.rawImage,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.surfaceMuted,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.broken_image,
                                          size: 40, color: AppColors.navyMuted),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Missing raw image: ${_currentSample.rawImage}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text('Tap to Enlarge',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          // Reticle Overlay / Viewfinder Guides
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          // Neutral Sample Tag
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _neutralTitle(_currentSample),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warningAmber
                                    .withValues(alpha: 0.9),
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
                  ),
                  const SizedBox(height: 14),

                  // Simulated Capture Quality Indicators
                  const Text(
                    'Simulated Capture Checks (Demo Indicators)',
                    style: TextStyle(
                      fontSize: 13,
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
                          'Simulated check: Resolution acceptable for contour extraction',
                        ),
                        const Divider(height: 14, color: AppColors.border),
                        _buildCheckRow(
                          'Lighting / Shadows',
                          'UNIFORM',
                          true,
                          'Simulated check: Diffused ambient daylight; no glare flares',
                        ),
                        const Divider(height: 14, color: AppColors.border),
                        _buildCheckRow(
                          'Camera Angle / Blur',
                          'ALIGNED',
                          true,
                          'Simulated check: Vertical alignment verified; no motion blur',
                        ),
                        const Divider(height: 14, color: AppColors.border),
                        _buildCheckRow(
                          'Reference Target',
                          capture.referenceVisible ? 'VISIBLE' : 'NOT DETECTED',
                          capture.referenceVisible,
                          'Simulated check: Calibration scale marker visible in frame',
                        ),
                        const Divider(height: 14, color: AppColors.border),
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
                  const SizedBox(height: 18),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AiAnalysisScreen(
                              inspectionRepository: widget.inspectionRepository,
                              inspectionId: widget.inspectionId,
                              lotId: widget.lotId,
                              farmerName: widget.farmerName,
                              procurementCentre: widget.procurementCentre,
                              inspectorId: widget.inspectorId,
                              onionVariety: widget.onionVariety,
                              lotQuantity: widget.lotQuantity,
                              selectedSamples: widget.selectedSamples,
                              currentSampleIndex: widget.currentSampleIndex,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm Sample',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Choose Another Sample'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guidanceBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: AppColors.navyText),
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
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
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
                  fontSize: 10.5,
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
