import 'package:flutter/material.dart';
import '../models/grading_rule_model.dart';
import '../models/inspection_model.dart';
import '../models/sample_model.dart';
import '../repositories/config_repository.dart';
import '../repositories/inspection_repository.dart';
import '../services/aggregation_service.dart';
import '../services/grading_engine.dart';
import '../utils/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import 'grading_config_screen.dart';
import 'human_review_screen.dart';

class AggregationScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;
  final String inspectionId;
  final String lotId;
  final String farmerName;
  final String procurementCentre;
  final String inspectorId;
  final String onionVariety;
  final String lotQuantity;
  final List<SampleModel> selectedSamples;

  const AggregationScreen({
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
  });

  @override
  State<AggregationScreen> createState() => _AggregationScreenState();
}

class _AggregationScreenState extends State<AggregationScreen> {
  final ConfigRepository _configRepository = ConfigRepository();
  late AggregatedQualityResult _aggregatedResult;
  DynamicGradingConfig _activeConfig = DynamicGradingConfig.defaultNashikRed;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _computeAggregation();
  }

  Future<void> _computeAggregation() async {
    // Strict count-based multi-sample aggregation
    _aggregatedResult = AggregationService.aggregateSamples(widget.selectedSamples);
    final config = await _configRepository.getConfig();
    if (mounted) {
      setState(() {
        _activeConfig = config;
        _isLoading = false;
      });
    }
  }

  void _proceedToGradingDecision() {
    // Run grading engine
    final decision = GradingEngine.evaluate(
      aggregated: _aggregatedResult,
      config: _activeConfig,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HumanReviewScreen(
          inspectionRepository: widget.inspectionRepository,
          inspectionId: widget.inspectionId,
          lotId: widget.lotId,
          farmerName: widget.farmerName,
          procurementCentre: widget.procurementCentre,
          inspectorId: widget.inspectorId,
          onionVariety: widget.onionVariety,
          lotQuantity: widget.lotQuantity,
          selectedSamples: widget.selectedSamples,
          aggregatedResult: _aggregatedResult,
          rulesSnapshot: _activeConfig,
          gradingDecision: decision,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final agg = _aggregatedResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Multi-Sample Aggregation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DisclaimerBanner.info(
              message: 'Underlying counts from all selected sample captures are summed directly. Percentages are derived from aggregated totals, never by averaging sample percentages.',
            ),
            const SizedBox(height: 16),

            // Sample Summary Table
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
                  const Text(
                    'Sample Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.selectedSamples.map((sample) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${sample.sampleId} — ${sample.name}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navyText,
                            ),
                          ),
                          Text(
                            '${sample.analysis.totalOnions} onions',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL AGGREGATED',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tealDark,
                        ),
                      ),
                      Text(
                        '${agg.totalOnions} onions',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                  if (agg.isValid) ...[
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.healthyGreen),
                        SizedBox(width: 4),
                        Text(
                          'Validation passed: Category counts equal total onions',
                          style: TextStyle(fontSize: 11, color: AppColors.healthyGreen, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Aggregated Quality Composition
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
                  const Text(
                    'Aggregated Defect Composition',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _aggBarRow('Healthy', agg.totalHealthy, agg.healthyPercent, AppColors.healthyGreen),
                  const SizedBox(height: 10),
                  _aggBarRow('Surface Defect', agg.totalSurfaceDefect, agg.surfaceDefectPercent, AppColors.warningAmber),
                  const SizedBox(height: 10),
                  _aggBarRow('Severe Defect (Rot)', agg.totalSevereDefect, agg.severeDefectPercent, AppColors.rejectRed),
                  const SizedBox(height: 10),
                  _aggBarRow('Sprouting', agg.totalSprouting, agg.sproutingPercent, AppColors.warningAmber),
                  const SizedBox(height: 10),
                  _aggBarRow('Undersized', agg.totalUndersized, agg.undersizedPercent, AppColors.infoBlue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Combined Diameter Metric
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.straighten, size: 16, color: AppColors.tealDark),
                      SizedBox(width: 6),
                      Text(
                        'Combined Metric Calibration (Demo Estimate)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricBox('Avg Diameter', '${agg.avgDiameter.toStringAsFixed(1)} mm'),
                      _metricBox('Min Diameter', '${agg.minDiameter} mm'),
                      _metricBox('Max Diameter', '${agg.maxDiameter} mm'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Grading Configuration Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.tealBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Grading Rules',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GradingConfigScreen(),
                            ),
                          );
                          _computeAggregation();
                        },
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Edit Rules', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grade A: Sprouting ≤ ${_activeConfig.sproutingGradeAMax}%, Rot ≤ ${_activeConfig.rotGradeAMax}%, Diameters ${_activeConfig.diameterMinMm}-${_activeConfig.diameterMaxMm}mm',
                    style: const TextStyle(fontSize: 11, color: AppColors.navyMuted),
                  ),
                  Text(
                    'URS: Sprouting ≤ ${_activeConfig.sproutingUrsMax}%, Rot ≤ ${_activeConfig.rotUrsMax}%',
                    style: const TextStyle(fontSize: 11, color: AppColors.navyMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue Button
            ElevatedButton(
              onPressed: _proceedToGradingDecision,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Apply Grading Rules & Review'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aggBarRow(String label, int count, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyDark),
            ),
            Text(
              '$count (${percent.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.navyMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tealDark),
        ),
      ],
    );
  }
}
