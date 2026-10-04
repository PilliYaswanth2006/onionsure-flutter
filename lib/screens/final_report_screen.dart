import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/progress_stepper.dart';
import '../widgets/quality_badge.dart';
import 'qr_verification_screen.dart';

class FinalReportScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;
  final InspectionModel inspection;
  final List<SampleModel>? selectedSamples;

  const FinalReportScreen({
    super.key,
    required this.inspectionRepository,
    required this.inspection,
    this.selectedSamples,
  });

  @override
  State<FinalReportScreen> createState() => _FinalReportScreenState();
}

class _FinalReportScreenState extends State<FinalReportScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _autoSave();
  }

  Future<void> _autoSave() async {
    await widget.inspectionRepository.saveInspection(widget.inspection);
    if (mounted) {
      setState(() {
        _isSaved = true;
      });
    }
  }

  void _generatePdf() async {
    try {
      await PdfService.printOrSharePdf(widget.inspection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.rejectRed,
          ),
        );
      }
    }
  }

  void _openQrVerification() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QrVerificationScreen(inspection: widget.inspection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insp = widget.inspection;
    final agg = insp.aggregatedResult;
    final rules = insp.rulesUsed;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            tooltip: 'Verify',
            icon: const Icon(Icons.qr_code),
            onPressed: _openQrVerification,
          ),
          IconButton(
            tooltip: 'Generate PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceMuted,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 5 of 5 · Quality Report',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Audit trail, digital report generation and offline QR verification.',
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
                  // Official Header Badge
                  Container(
                    width: double.infinity,
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
                              'DIGITAL QUALITY REPORT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.tealDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                            QualityBadge(label: insp.finalResult, large: true),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inspection ID: ${insp.inspectionId}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark),
                        ),
                        Text(
                          'Date: ${dateFormat.format(insp.timestamp)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.navyMuted),
                        ),
                        if (_isSaved) ...[
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Icon(Icons.save_outlined,
                                  size: 12, color: AppColors.healthyGreen),
                              SizedBox(width: 4),
                              Text('Saved to offline storage (Pending Sync)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.healthyGreen)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Section 1: Lot & Producer Details
                  _buildSectionHeader('1. Lot & Procurement Information'),
                  _buildCard([
                    _buildInfoRow('Lot ID', insp.lotId),
                    _buildInfoRow('Farmer / Producer', insp.farmerName),
                    _buildInfoRow('Procurement Centre', insp.procurementCentre),
                    _buildInfoRow('Inspector ID', insp.inspectorId),
                    _buildInfoRow('Onion Variety', insp.onionVariety),
                    _buildInfoRow('Lot Quantity', insp.lotQuantity),
                  ]),
                  const SizedBox(height: 14),

                  // Section 2: Sampling & Metric Calibration
                  _buildSectionHeader('2. Sampling & Metric Measurements'),
                  _buildCard([
                    _buildInfoRow('Samples Analyzed',
                        '${insp.selectedSampleIds.length} (${insp.selectedSampleIds.join(", ")})'),
                    _buildInfoRow(
                        'Total Onions Analyzed', '${agg.totalOnions} onions'),
                    _buildInfoRow('Average Diameter',
                        '${agg.avgDiameter.toStringAsFixed(1)} mm (Demo Estimate)'),
                    _buildInfoRow('Diameter Range',
                        '${agg.minDiameter} mm - ${agg.maxDiameter} mm'),
                  ]),
                  const SizedBox(height: 14),

                  // Section 3: Aggregated Quality Composition
                  _buildSectionHeader('3. Aggregated Quality Composition'),
                  _buildCard([
                    _buildPercentRow('Healthy Onions', agg.totalHealthy,
                        agg.healthyPercent, AppColors.healthyGreen),
                    _buildPercentRow('Surface Defects', agg.totalSurfaceDefect,
                        agg.surfaceDefectPercent, AppColors.warningAmber),
                    _buildPercentRow(
                        'Severe Visible Defect',
                        agg.totalSevereDefect,
                        agg.severeDefectPercent,
                        AppColors.rejectRed),
                    _buildPercentRow('Sprouting', agg.totalSprouting,
                        agg.sproutingPercent, AppColors.warningAmber),
                    _buildPercentRow('Undersized Onions', agg.totalUndersized,
                        agg.undersizedPercent, AppColors.infoBlue),
                  ]),
                  const SizedBox(height: 14),

                  // Section 4: Rules Snapshot & Grading Decision
                  _buildSectionHeader('4. Applied Configuration & Outcome'),
                  _buildCard([
                    _buildInfoRow('Engine Observation', insp.engineResult),
                    _buildInfoRow('Final Assessment', insp.finalResult),
                    _buildInfoRow('Diameter Rules Snapshot',
                        '${rules.diameterMinMm}mm - ${rules.diameterMaxMm}mm'),
                    _buildInfoRow('Grade A Sprouting Limit',
                        '${rules.sproutingGradeAMax}%'),
                    _buildInfoRow('Grade A Severe Defect Limit',
                        '${rules.rotGradeAMax}%'),
                    _buildInfoRow(
                        'URS Sprouting Limit', '${rules.sproutingUrsMax}%'),
                    _buildInfoRow(
                        'URS Severe Defect Limit', '${rules.rotUrsMax}%'),
                    if (insp.humanReview != null) ...[
                      const Divider(height: 12, color: AppColors.border),
                      _buildInfoRow('Inspector Review Action',
                          insp.humanReview!.action.toUpperCase()),
                      if (insp.humanReview!.reason != null)
                        _buildInfoRow(
                            'Review Reason', insp.humanReview!.reason!),
                      if (insp.humanReview!.internalVerificationPerformed) ...[
                        _buildInfoRow(
                          'Physical Cut Test',
                          'PERFORMED: ${insp.humanReview!.internalVerificationResult}',
                        ),
                        if (insp.humanReview!.cutTestExaminedCount != null)
                          _buildInfoRow(
                            'Cut Test Sample',
                            '${insp.humanReview!.cutTestExaminedCount} examined • ${insp.humanReview!.cutTestDefectCount ?? 0} defects',
                          ),
                      ] else
                        _buildInfoRow('Physical Cut Test', 'Not Performed'),
                      if (insp.humanReview!.internalVerificationNotes != null)
                        _buildInfoRow('Cut Test Notes',
                            insp.humanReview!.internalVerificationNotes!),
                    ],
                  ]),
                  const SizedBox(height: 14),

                  // Section 5: Evidence Gallery
                  if (widget.selectedSamples != null &&
                      widget.selectedSamples!.isNotEmpty) ...[
                    _buildSectionHeader('5. Sample Photographic Evidence'),
                    ...widget.selectedSamples!.map((sample) {
                      final numStr =
                          sample.sampleId.replaceAll(RegExp(r'[^0-9]'), '');
                      final label =
                          '${sample.sampleId} · Sample ${numStr.padLeft(2, '0')}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Raw Capture',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.navyMuted)),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: GestureDetector(
                                          onTap: () => ImageViewerDialog.show(
                                            context,
                                            imagePath: sample.rawImage,
                                            title: '$label — Raw Capture',
                                          ),
                                          child: Container(
                                            color: Colors.black12,
                                            child: AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: Image.asset(
                                                sample.rawImage,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Prepared CV Output',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.navyMuted)),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: GestureDetector(
                                          onTap: () => ImageViewerDialog.show(
                                            context,
                                            imagePath: sample.annotatedImage,
                                            title: '$label — Prepared CV Output',
                                          ),
                                          child: Container(
                                            color: Colors.black12,
                                            child: AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: Image.asset(
                                                sample.annotatedImage,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],

                  // Audit Disclaimer Banner
                  const DisclaimerBanner.info(
                    message: AppConstants.honestPrototypeDisclaimer,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text(
                        'Generate Quality Assessment Report',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: _openQrVerification,
                      icon: const Icon(Icons.qr_code, size: 20),
                      label: const Text(
                        'Open QR Verification',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Return to Home'),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.navyMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentRow(
      String label, int count, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyDark)),
            ],
          ),
          Text(
            '$count (${percent.toStringAsFixed(1)}%)',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
