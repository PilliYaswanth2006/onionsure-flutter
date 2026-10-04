import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
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
    'Preparing demonstration image...',
    'Detecting onion contours & bounding boxes...',
    'Analyzing visible external defects & sprouting...',
    'Preparing diameter & metric calibrations...',
    'Loading prepared CV results from samples.json...',
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_simulationStep < _progressSteps.length - 1) {
        setState(() {
          _simulationStep++;
        });
      } else {
        _timer?.cancel();
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
        title: Text('Sample Analysis ($sampleNum/$totalSamples)'),
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 4),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _isSimulating
                ? _buildSimulationView()
                : _buildResultView(currentSample, isLastSample, sampleNum, totalSamples),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationView() {
    final progress = (_simulationStep + 1) / _progressSteps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 48,
                color: AppColors.tealPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Running Prepared CV Pipeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _progressSteps[_simulationStep],
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.tealDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealPrimary),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading precomputed demonstration results from samples.json',
              style: TextStyle(fontSize: 11, color: AppColors.navyMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(SampleModel currentSample, bool isLastSample, int sampleNum, int totalSamples) {
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

          // Annotated Visual Result
          Container(
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
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceMuted,
                      child: Center(
                        child: Text('Missing annotated image: ${currentSample.annotatedImage}'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sample Summary Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentSample.sampleId}: ${currentSample.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => OnionDetailDialog(sample: currentSample),
                  );
                },
                icon: const Icon(Icons.list_alt, size: 16),
                label: const Text('View Onions', style: TextStyle(fontSize: 12)),
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
                _categoryRow('Healthy Onions', counts.healthy, counts.healthyPercent(total), AppColors.healthyGreen),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Surface Defect', counts.surfaceDefect, counts.surfaceDefectPercent(total), AppColors.warningAmber),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Severe Defect (Visible Rot)', counts.severeDefect, counts.severeDefectPercent(total), AppColors.rejectRed),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Sprouting', counts.sprouting, counts.sproutingPercent(total), AppColors.warningAmber),
                const Divider(height: 12, color: AppColors.border),
                _categoryRow('Undersized Onions', counts.undersized, counts.undersizedPercent(total), AppColors.infoBlue),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Measurement Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.straighten, size: 16, color: AppColors.navyText),
                    SizedBox(width: 6),
                    Text(
                      'Estimated Diameters (Demo Measurement)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Average: ${analysis.avgDiameter.toStringAsFixed(1)} mm',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyText),
                    ),
                    Text(
                      'Min: ${analysis.minDiameter} mm',
                      style: const TextStyle(fontSize: 12, color: AppColors.navyMuted),
                    ),
                    Text(
                      'Max: ${analysis.maxDiameter} mm',
                      style: const TextStyle(fontSize: 12, color: AppColors.navyMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary Navigation Button
          ElevatedButton(
            onPressed: _proceedToNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastSample
                      ? 'Proceed to Multi-Sample Aggregation'
                      : 'Analyze Next Sample (${sampleNum + 1}/$totalSamples)',
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
    return Row(
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
              fontWeight: FontWeight.w500,
              color: AppColors.navyText,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            '(${percent.toStringAsFixed(1)}%)',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
