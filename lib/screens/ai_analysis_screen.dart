import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/onion_detail_dialog.dart';
import '../widgets/progress_stepper.dart';
import 'aggregation_screen.dart';
import 'smart_capture_screen.dart';

class AiAnalysisScreen extends StatefulWidget {
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

  const AiAnalysisScreen({
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
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  bool _isSimulating = true;
  int _simulationStep = 0;
  Timer? _timer;

  final List<String> _progressSteps = [
    'Loading prepared sample data...',
    'Validating sample records...',
    'Preparing analysis view...',
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_simulationStep < _progressSteps.length - 1) {
        setState(() {
          _simulationStep++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isSimulating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _neutralTitle(SampleModel s) {
    final numStr = s.sampleId.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNum =
        numStr.isNotEmpty ? numStr.padLeft(2, '0') : s.sampleId;
    return '${s.sampleId} · Sample $formattedNum';
  }

  void _proceedToNext() {
    final nextIndex = widget.currentSampleIndex + 1;
    if (nextIndex < widget.selectedSamples.length) {
      // Analyze next selected sample
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SmartCaptureScreen(
            inspectionRepository: widget.inspectionRepository,
            inspectionId: widget.inspectionId,
            lotId: widget.lotId,
            farmerName: widget.farmerName,
            procurementCentre: widget.procurementCentre,
            inspectorId: widget.inspectorId,
            onionVariety: widget.onionVariety,
            lotQuantity: widget.lotQuantity,
            selectedSamples: widget.selectedSamples,
            currentSampleIndex: nextIndex,
          ),
        ),
      );
    } else {
      // All selected samples analyzed, proceed to aggregation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AggregationScreen(
            inspectionRepository: widget.inspectionRepository,
            inspectionId: widget.inspectionId,
            lotId: widget.lotId,
            farmerName: widget.farmerName,
            procurementCentre: widget.procurementCentre,
            inspectorId: widget.inspectorId,
            onionVariety: widget.onionVariety,
            lotQuantity: widget.lotQuantity,
            selectedSamples: widget.selectedSamples,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSample = widget.selectedSamples[widget.currentSampleIndex];
    final sampleNum = widget.currentSampleIndex + 1;
    final totalSamples = widget.selectedSamples.length;
    final isLastSample = sampleNum == totalSamples;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quality Analysis',
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
          const ProgressStepper(currentStep: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceMuted,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 4 of 5 · Quality Analysis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Review detected onion categories and size measurements.',
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
            child: _isSimulating
                ? _buildSimulationView()
                : _buildResultView(
                    currentSample, isLastSample, sampleNum, totalSamples),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationView() {
    final progress = (_simulationStep + 1) / _progressSteps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 42,
                color: AppColors.tealPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Preparing Sample Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'DEMO MODE: Prepared Computer Vision Result',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tealDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Checklist
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(_progressSteps.length, (idx) {
                  final isDone = idx < _simulationStep;
                  final isCurrent = idx == _simulationStep;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle
                              : isCurrent
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                          size: 16,
                          color: isDone
                              ? AppColors.healthyGreen
                              : isCurrent
                                  ? AppColors.tealPrimary
                                  : AppColors.navyMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _progressSteps[idx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AppColors.navyDark
                                  : AppColors.navyMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.tealPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(SampleModel currentSample, bool isLastSample,
      int sampleNum, int totalSamples) {
    final analysis = currentSample.analysis;
    final counts = analysis.categoryCounts;
    final total = analysis.totalOnions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mandatory Honest Banner
          const DisclaimerBanner(
            message: AppConstants.preparedResultNotice,
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 12),

          // Annotated Visual Result (BoxFit.contain & Tap to Enlarge)
          GestureDetector(
            onTap: () {
              ImageViewerDialog.show(
                context,
                imagePath: currentSample.annotatedImage,
                title: '${currentSample.sampleId}: Annotated CV Output',
                subtitle: 'Tap anywhere to zoom/pan',
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navyDark),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(
                      currentSample.annotatedImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceMuted,
                        child: Center(
                          child: Text(
                              'Missing annotated image: ${currentSample.annotatedImage}'),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${currentSample.sampleId}: Annotated CV Output',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
                          Icon(Icons.zoom_in, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text('Tap to Enlarge',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sample Summary Title (Responsive Row)
          Row(
            children: [
              Expanded(
                child: Text(
                  _neutralTitle(currentSample),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        OnionDetailDialog(sample: currentSample),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Onion Details',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 13),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Category Counts Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detected Quality Breakdown',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      'Total: $total Onions',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _categoryRow('Healthy Onions', counts.healthy,
                    counts.healthyPercent(total), AppColors.healthyGreen),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Surface Defect', counts.surfaceDefect,
                    counts.surfaceDefectPercent(total), AppColors.warningAmber),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Severe Visible Defect', counts.severeDefect,
                    counts.severeDefectPercent(total), AppColors.rejectRed),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Sprouting', counts.sprouting,
                    counts.sproutingPercent(total), AppColors.warningAmber),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Undersized Onions', counts.undersized,
                    counts.undersizedPercent(total), AppColors.infoBlue),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.healthyGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.healthyGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: AppColors.healthyGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Count check passed · ${counts.totalCategorized}/$total onions categorized',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.healthyGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Technical Measurements & Calibration (Collapsible)
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                leading: const Icon(Icons.straighten,
                    size: 20, color: AppColors.tealDark),
                title: const Text(
                  'Technical Measurements & Calibration',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
                subtitle: Text(
                  'Avg: ${analysis.avgDiameter.toStringAsFixed(1)} mm • Demo estimate',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.navyMuted),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _metricCol('Average',
                                '${analysis.avgDiameter.toStringAsFixed(1)} mm'),
                            _metricCol('Minimum', '${analysis.minDiameter} mm'),
                            _metricCol('Maximum', '${analysis.maxDiameter} mm'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Demo Measurement: Physical diameters estimated using prototype calibration baseline. Production deployment requires validated metric targets.',
                          style: TextStyle(
                              fontSize: 10.5, color: AppColors.navyMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary Navigation Button (Responsive & Overflow-Safe)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: _proceedToNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isLastSample
                        ? 'Proceed to Multi-Sample Aggregation'
                        : 'Analyze Next Sample (${sampleNum + 1} of $totalSamples)',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String label, int count, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${percent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.navyMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark),
        ),
      ],
    );
  }
}
