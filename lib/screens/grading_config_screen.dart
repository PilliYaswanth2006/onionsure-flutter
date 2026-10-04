import 'package:flutter/material.dart';
import '../models/grading_rule_model.dart';
import '../repositories/config_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/disclaimer_banner.dart';

class GradingConfigScreen extends StatefulWidget {
  const GradingConfigScreen({super.key});

  @override
  State<GradingConfigScreen> createState() => _GradingConfigScreenState();
}

class _GradingConfigScreenState extends State<GradingConfigScreen> {
  final ConfigRepository _repo = ConfigRepository();
  bool _isLoading = true;

  late int _diameterMin;
  late int _diameterMax;
  late double _sproutingGradeA;
  late double _rotGradeA;
  late double _surfaceDefectGradeA;
  late double _undersizedGradeA;

  late double _sproutingUrs;
  late double _rotUrs;
  late double _surfaceDefectUrs;
  late double _undersizedUrs;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final cfg = await _repo.getConfig();
    setState(() {
      _diameterMin = cfg.diameterMinMm;
      _diameterMax = cfg.diameterMaxMm;
      _sproutingGradeA = cfg.sproutingGradeAMax;
      _rotGradeA = cfg.rotGradeAMax;
      _surfaceDefectGradeA = cfg.surfaceDefectGradeAMax;
      _undersizedGradeA = cfg.undersizedGradeAMax;

      _sproutingUrs = cfg.sproutingUrsMax;
      _rotUrs = cfg.rotUrsMax;
      _surfaceDefectUrs = cfg.surfaceDefectUrsMax;
      _undersizedUrs = cfg.undersizedUrsMax;

      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    final updated = DynamicGradingConfig(
      diameterMinMm: _diameterMin,
      diameterMaxMm: _diameterMax,
      sproutingGradeAMax: _sproutingGradeA,
      rotGradeAMax: _rotGradeA,
      surfaceDefectGradeAMax: _surfaceDefectGradeA,
      undersizedGradeAMax: _undersizedGradeA,
      sproutingUrsMax: _sproutingUrs,
      rotUrsMax: _rotUrs,
      surfaceDefectUrsMax: _surfaceDefectUrs,
      undersizedUrsMax: _undersizedUrs,
    );
    await _repo.saveConfig(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Configuration saved locally'),
          backgroundColor: AppColors.tealPrimary,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Grading Rules'),
        content: const Text(
          'Are you sure you want to restore the default Nashik Red parameters? All custom tolerance thresholds will be reverted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejectRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset Defaults'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _resetDefaults();
    }
  }

  Future<void> _resetDefaults() async {
    await _repo.resetToDefaults();
    await _loadConfig();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default Nashik Red parameters.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grading Rules'),
        actions: [
          TextButton(
            onPressed: _confirmReset,
            child: const Text('Reset',
                style: TextStyle(color: AppColors.rejectRed)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DisclaimerBanner.warning(
              message:
                  'Prototype Configuration: Dynamic rules configured here evaluate field lots. Saving an inspection creates an immutable snapshot of rules used.',
            ),
            const SizedBox(height: 16),

            // 01 Sizing Criteria
            _buildSectionHeader(
                '01 · Size / Metric Calibration (Nashik Red Standard)'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSlider(
                    label: 'Minimum Diameter (mm)',
                    value: _diameterMin.toDouble(),
                    min: 25,
                    max: 50,
                    divisions: 25,
                    unit: 'mm',
                    onChanged: (val) =>
                        setState(() => _diameterMin = val.toInt()),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'Maximum Diameter (mm)',
                    value: _diameterMax.toDouble(),
                    min: 55,
                    max: 90,
                    divisions: 35,
                    unit: 'mm',
                    onChanged: (val) =>
                        setState(() => _diameterMax = val.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grade A Tolerances
            _buildSectionHeader(
                '02 · Grade A Quality Tolerances (Strict Mandi Standard)'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSlider(
                    label: 'Max Sprouting (%)',
                    value: _sproutingGradeA,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    unit: '%',
                    onChanged: (val) => setState(() => _sproutingGradeA = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'Max Severe Visible Defect (%)',
                    value: _rotGradeA,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    unit: '%',
                    onChanged: (val) => setState(() => _rotGradeA = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'Max Surface Defect (%)',
                    value: _surfaceDefectGradeA,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    unit: '%',
                    onChanged: (val) =>
                        setState(() => _surfaceDefectGradeA = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'Max Undersized Onions (%)',
                    value: _undersizedGradeA,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    unit: '%',
                    onChanged: (val) => setState(() => _undersizedGradeA = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // URS Tolerances
            _buildSectionHeader('03 · Under-Relaxed Specifications (URS)'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSlider(
                    label: 'URS Max Sprouting (%)',
                    value: _sproutingUrs,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    unit: '%',
                    onChanged: (val) => setState(() => _sproutingUrs = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'URS Max Severe Visible Defect (%)',
                    value: _rotUrs,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    unit: '%',
                    onChanged: (val) => setState(() => _rotUrs = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'URS Max Surface Defect (%)',
                    value: _surfaceDefectUrs,
                    min: 5,
                    max: 30,
                    divisions: 25,
                    unit: '%',
                    onChanged: (val) => setState(() => _surfaceDefectUrs = val),
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildSlider(
                    label: 'URS Max Undersized (%)',
                    value: _undersizedUrs,
                    min: 5,
                    max: 25,
                    divisions: 20,
                    unit: '%',
                    onChanged: (val) => setState(() => _undersizedUrs = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _saveConfig,
                icon: const Icon(Icons.save, size: 18),
                label: const Text(
                  'Save Configuration',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDark,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navyText),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.tealPrimary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
