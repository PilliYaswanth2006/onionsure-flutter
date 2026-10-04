import 'package:flutter/material.dart';
import '../models/grading_rule_model.dart';
import '../models/human_review_model.dart';
import '../models/inspection_model.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../services/grading_engine.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/quality_badge.dart';
import 'final_report_screen.dart';

class HumanReviewScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;
  final String inspectionId;
  final String lotId;
  final String farmerName;
  final String procurementCentre;
  final String inspectorId;
  final String onionVariety;
  final String lotQuantity;
  final List<SampleModel> selectedSamples;
  final AggregatedQualityResult aggregatedResult;
  final DynamicGradingConfig rulesSnapshot;
  final GradingDecision gradingDecision;

  const HumanReviewScreen({
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
    required this.aggregatedResult,
    required this.rulesSnapshot,
    required this.gradingDecision,
  });

  @override
  State<HumanReviewScreen> createState() => _HumanReviewScreenState();
}

class _HumanReviewScreenState extends State<HumanReviewScreen> {
  // Physical cut / internal verification fields
  bool _cutTestPerformed = false;
  String _cutTestResult = 'Normal / Clear';
  final TextEditingController _cutExaminedCtrl =
      TextEditingController(text: '5');
  final TextEditingController _cutDefectCtrl =
      TextEditingController(text: '0');
  final TextEditingController _cutTestNotesCtrl = TextEditingController();

  // Review override state
  String? _overrideDecision; // 'Grade A', 'URS', 'Reject'
  final TextEditingController _overrideReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _cutExaminedCtrl.dispose();
    _cutDefectCtrl.dispose();
    _cutTestNotesCtrl.dispose();
    _overrideReasonCtrl.dispose();
    super.dispose();
  }

  void _finalizeWithAction(String action) {
    if (_cutTestPerformed) {
      final examined = int.tryParse(_cutExaminedCtrl.text.trim()) ?? 0;
      final defects = int.tryParse(_cutDefectCtrl.text.trim()) ?? 0;
      if (examined <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter a valid number of examined onions (> 0).'),
            backgroundColor: AppColors.rejectRed,
          ),
        );
        return;
      }
      if (defects < 0 || defects > examined) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Defects observed cannot exceed total onions examined.'),
            backgroundColor: AppColors.rejectRed,
          ),
        );
        return;
      }
    }

    String finalGrade = widget.gradingDecision.outcome;
    String? reason;

    if (action == 'accepted') {
      finalGrade = widget.gradingDecision.outcome;
      reason = 'Inspector Review: CONFIRMED';
    } else if (action == 'corrected') {
      if (_overrideDecision == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an override grade')),
        );
        return;
      }
      if (_overrideReasonCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please enter an official audit reason for the override')),
        );
        return;
      }
      finalGrade = _overrideDecision!;
      reason = _overrideReasonCtrl.text.trim();
    } else if (action == 'rejected') {
      finalGrade = 'Reject';
      reason = _overrideReasonCtrl.text.trim().isNotEmpty
          ? _overrideReasonCtrl.text.trim()
          : 'Inspector manual rejection';
    }

    final reviewRecord = HumanReviewRecord(
      originalResult: widget.gradingDecision.outcome,
      finalResult: finalGrade,
      action: action,
      reason: reason,
      inspectorId: widget.inspectorId,
      timestamp: DateTime.now(),
      internalVerificationPerformed: _cutTestPerformed,
      internalVerificationResult:
          _cutTestPerformed ? _cutTestResult : 'Not Performed',
      internalVerificationNotes: _cutTestNotesCtrl.text.trim().isNotEmpty
          ? _cutTestNotesCtrl.text.trim()
          : null,
      cutTestExaminedCount: _cutTestPerformed
          ? int.tryParse(_cutExaminedCtrl.text.trim())
          : null,
      cutTestDefectCount: _cutTestPerformed
          ? int.tryParse(_cutDefectCtrl.text.trim())
          : null,
    );

    final inspection = InspectionModel(
      inspectionId: widget.inspectionId,
      lotId: widget.lotId,
      farmerName: widget.farmerName,
      procurementCentre: widget.procurementCentre,
      inspectorId: widget.inspectorId,
      onionVariety: widget.onionVariety,
      lotQuantity: widget.lotQuantity,
      timestamp: DateTime.now(),
      selectedSampleIds: widget.selectedSamples.map((s) => s.sampleId).toList(),
      aggregatedResult: widget.aggregatedResult,
      rulesUsed: widget.rulesSnapshot, // Immutable snapshot
      engineResult: widget.gradingDecision.outcome,
      engineExplanations: widget.gradingDecision.explanations,
      finalResult: finalGrade,
      humanReview: reviewRecord,
      syncStatus: 'Pending Sync',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FinalReportScreen(
          inspectionRepository: widget.inspectionRepository,
          inspection: inspection,
          selectedSamples: widget.selectedSamples,
        ),
      ),
    );
  }

  void _showCorrectionDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Inspector Override / Correction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select corrected classification:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _overrideDecision ??
                    (widget.gradingDecision.outcome == 'Reject'
                        ? 'URS'
                        : 'Grade A'),
                items: const [
                  DropdownMenuItem(value: 'Grade A', child: Text('Grade A')),
                  DropdownMenuItem(
                      value: 'URS', child: Text('URS (Under-Relaxed)')),
                  DropdownMenuItem(value: 'Reject', child: Text('Reject Lot')),
                ],
                onChanged: (val) {
                  setDialogState(() => _overrideDecision = val);
                  setState(() => _overrideDecision = val);
                },
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              const SizedBox(height: 12),
              const Text('Mandatory audit justification:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _overrideReasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText:
                      'e.g., Physical check showed surface blemish does not penetrate basal plate',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _finalizeWithAction('corrected');
              },
              child: const Text('Submit Override'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decision = widget.gradingDecision;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grading Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: SYSTEM ASSESSMENT
            _buildSectionHeader('SYSTEM ASSESSMENT'),
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
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
                              const Text(
                                'Engine Decision',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                decision.outcome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        QualityBadge(label: decision.outcome, large: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Rule Breaches & Observations',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (decision.failureReasons.isNotEmpty)
                      ...decision.failureReasons.map((failure) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.cancel,
                                    size: 15, color: AppColors.rejectRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    failure,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.rejectRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 15, color: AppColors.healthyGreen),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'All parameters satisfy Grade A specifications.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.healthyGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (decision.requiresReview &&
                        decision.reviewReason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningAmberBg,
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: AppColors.warningAmberBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: AppColors.warningAmber),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                decision.reviewReason!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        title: const Text(
                          'Rule Evaluation Details',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tealDark),
                        ),
                        children: [
                          ...decision.ruleChecks.map((chk) {
                            final isPass = chk.startsWith('✓');
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isPass ? Icons.check_circle : Icons.cancel,
                                    size: 14,
                                    color: isPass
                                        ? AppColors.healthyGreen
                                        : AppColors.rejectRed,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      chk,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isPass
                                            ? AppColors.navyDark
                                            : AppColors.rejectRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 6),
                          ...decision.explanations.map((exp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $exp',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.navyMuted),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: PHYSICAL VERIFICATION
            _buildSectionHeader('PHYSICAL VERIFICATION'),
            _buildInternalQualitySection(),
            const SizedBox(height: 20),

            // Section 3: INSPECTOR DECISION
            _buildSectionHeader('INSPECTOR DECISION'),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _finalizeWithAction('accepted'),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text(
                      'Confirm Assessment',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                    onPressed: _showCorrectionDialog,
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: const Text(
                      'Override Assessment',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                      foregroundColor: AppColors.rejectRed,
                      side: const BorderSide(color: AppColors.rejectRedBorder),
                    ),
                    onPressed: () => _finalizeWithAction('rejected'),
                    icon: const Icon(Icons.block, size: 20),
                    label: const Text(
                      'Reject Lot',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.navyMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInternalQualitySection() {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(Icons.content_cut, size: 18, color: AppColors.tealDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Physical Internal Quality Verification',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const DisclaimerBanner.warning(
            message: AppConstants.internalRotNotice,
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Internal Cut Test Performed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'Bisect representative sample onions to verify internal scales',
                  style: TextStyle(fontSize: 11)),
              value: _cutTestPerformed,
              activeThumbColor: AppColors.tealPrimary,
              onChanged: (val) {
                setState(() {
                  _cutTestPerformed = val;
                });
              },
            ),
          ),
          if (_cutTestPerformed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cutExaminedCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Onions Examined',
                      hintText: 'e.g. 5',
                      prefixIcon: Icon(Icons.grain, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cutDefectCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Defects Observed',
                      hintText: 'e.g. 0',
                      prefixIcon: Icon(Icons.warning_amber, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _cutTestResult,
              decoration: const InputDecoration(
                labelText: 'Cut Test Result',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Normal / Clear',
                    child: Text('Normal / No Rot Detected')),
                DropdownMenuItem(
                    value: 'Bacterial Soft Rot Observed',
                    child: Text('Bacterial Soft Rot Observed')),
                DropdownMenuItem(
                    value: 'Black Mold / Aspergillus Observed',
                    child: Text('Black Mold / Aspergillus Observed')),
                DropdownMenuItem(
                    value: 'Basal Rot / Fusarium Observed',
                    child: Text('Basal Rot / Fusarium Observed')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _cutTestResult = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cutTestNotesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Scale Ring Observations & Audit Notes',
                hintText:
                    'e.g. 5 onions bisected, internal flesh firm, no ring rot',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
