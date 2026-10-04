import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../services/dataset_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/progress_stepper.dart';
import 'smart_capture_screen.dart';

class GuidedSamplingScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;
  final String inspectionId;
  final String lotId;
  final String farmerName;
  final String procurementCentre;
  final String inspectorId;
  final String onionVariety;
  final String lotQuantity;

  const GuidedSamplingScreen({
    super.key,
    required this.inspectionRepository,
    required this.inspectionId,
    required this.lotId,
    required this.farmerName,
    required this.procurementCentre,
    required this.inspectorId,
    required this.onionVariety,
    required this.lotQuantity,
  });

  @override
  State<GuidedSamplingScreen> createState() => _GuidedSamplingScreenState();
}

class _GuidedSamplingScreenState extends State<GuidedSamplingScreen> {
  final DatasetService _datasetService = DatasetService();
  List<SampleModel> _allSamples = [];
  final Set<String> _selectedSampleIds = {'S01', 'S03', 'S04'}; // Default demo selection
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    try {
      final samples = await _datasetService.loadSamples();
      if (mounted) {
        setState(() {
          _allSamples = samples;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int get _selectedOnionsTotal {
    int total = 0;
    for (final s in _allSamples) {
      if (_selectedSampleIds.contains(s.sampleId)) {
        total += s.analysis.totalOnions;
      }
    }
    return total;
  }

  void _proceedToCapture() {
    if (_selectedSampleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one sample to proceed.'),
          backgroundColor: AppColors.rejectRed,
        ),
      );
      return;
    }

    final selectedSamples = _allSamples
        .where((s) => _selectedSampleIds.contains(s.sampleId))
        .toList();

    Navigator.of(context).push(
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
          selectedSamples: selectedSamples,
          currentSampleIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guided Sampling'),
        actions: [
          if (_selectedSampleIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSampleIds.clear();
                });
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.rejectRed)),
            ),
        ],
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 2),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DisclaimerBanner(
                              message: AppConstants.samplingDisclaimer,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Select representative sample captures for this prototype inspection.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'In standard field assaying, multi-sample aggregation combines counts across batches to reduce sampling bias.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.navyMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._allSamples.map((sample) {
                              final isSelected = _selectedSampleIds.contains(sample.sampleId);
                              return _buildSampleCard(sample, isSelected);
                            }),
                          ],
                        ),
                      ),
          ),
          // Bottom Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selected Samples: ${_selectedSampleIds.length} / ${_allSamples.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          'Total Onions Represented: $_selectedOnionsTotal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.tealDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(110, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: _selectedSampleIds.isNotEmpty ? _proceedToCapture : null,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
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

  Widget _buildSampleCard(SampleModel sample, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.tealLight.withValues(alpha: 0.3) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.tealPrimary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSampleIds.remove(sample.sampleId);
              } else {
                _selectedSampleIds.add(sample.sampleId);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceMuted,
                    child: Image.asset(
                      sample.rawImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: AppColors.navyMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.navyDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sample.sampleId,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              sample.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sample.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.navyMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Onions: ${sample.analysis.totalOnions} | Sprouting: ${sample.analysis.categoryCounts.sprouting} | Defects: ${sample.analysis.categoryCounts.surfaceDefect + sample.analysis.categoryCounts.severeDefect}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkbox
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.tealPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedSampleIds.add(sample.sampleId);
                      } else {
                        _selectedSampleIds.remove(sample.sampleId);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
