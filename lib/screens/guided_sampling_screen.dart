import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sample_model.dart';
import '../repositories/inspection_repository.dart';
import '../services/dataset_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/image_viewer_dialog.dart';
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
  final List<SampleModel>? initialSamples;

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
    this.initialSamples,
  });

  @override
  State<GuidedSamplingScreen> createState() => _GuidedSamplingScreenState();
}

class _GuidedSamplingScreenState extends State<GuidedSamplingScreen> {
  final DatasetService _datasetService = DatasetService();
  List<SampleModel> _allSamples = [];
  final Set<String> _selectedSampleIds = {'S01', 'S03', 'S04'};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialSamples != null) {
      _allSamples = widget.initialSamples!;
      _isLoading = false;
    } else {
      _loadSamples();
    }
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

  String _neutralTitle(SampleModel s) {
    final numStr = s.sampleId.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNum =
        numStr.isNotEmpty ? numStr.padLeft(2, '0') : s.sampleId;
    return '${s.sampleId} · Sample $formattedNum';
  }

  void _takeSimulatedPhoto() {
    if (_allSamples.isEmpty) return;
    final randomSample = _allSamples[Random().nextInt(_allSamples.length)];
    setState(() {
      _selectedSampleIds.add(randomSample.sampleId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Simulated Camera Behavior: Captured and selected ${_neutralTitle(randomSample)} at random from prepared demo images.',
        ),
        backgroundColor: AppColors.tealDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openGalleryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose from Gallery',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                            ),
                            Text(
                              'Select from 5 predefined demonstration images (Offline)',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.navyMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _allSamples.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, idx) {
                        final sample = _allSamples[idx];
                        final isSel =
                            _selectedSampleIds.contains(sample.sampleId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: GestureDetector(
                            onTap: () {
                              ImageViewerDialog.show(
                                context,
                                imagePath: sample.rawImage,
                                title: _neutralTitle(sample),
                                subtitle: 'Sample Photo (Offline Gallery)',
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: AppColors.surfaceMuted,
                                child: Image.asset(
                                  sample.rawImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 20),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            _neutralTitle(sample),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Prepared demonstration tray for inspection',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.navyMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Checkbox(
                            value: isSel,
                            activeColor: AppColors.tealPrimary,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  _selectedSampleIds.add(sample.sampleId);
                                } else {
                                  _selectedSampleIds.remove(sample.sampleId);
                                }
                              });
                              setState(() {});
                            },
                          ),
                          onTap: () {
                            setModalState(() {
                              if (isSel) {
                                _selectedSampleIds.remove(sample.sampleId);
                              } else {
                                _selectedSampleIds.add(sample.sampleId);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Done (${_selectedSampleIds.length} selected)'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
        title: const Text('Sampling'),
        actions: [
          if (_allSamples.isNotEmpty &&
              _selectedSampleIds.length < _allSamples.length)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSampleIds.addAll(_allSamples.map((s) => s.sampleId));
                });
              },
              child: const Text('Select All',
                  style: TextStyle(
                      color: AppColors.tealDark, fontWeight: FontWeight.w600)),
            ),
          if (_selectedSampleIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSampleIds.clear();
                });
              },
              child: const Text('Clear',
                  style: TextStyle(color: AppColors.rejectRed)),
            ),
        ],
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceMuted,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2 of 5 · Sample Selection',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Select one or more prepared sample trays for this lot assessment.',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DisclaimerBanner(
                              message: AppConstants.samplingDisclaimer,
                            ),
                            const SizedBox(height: 12),

                            // Prototype Capture Guidance (Requirement 3: Appears before sampling/capture actions)
                            _buildCaptureGuidanceCard(),
                            const SizedBox(height: 14),

                            // Photo Input Actions: Take Photo / Choose from Gallery (Requirement 1)
                            _buildPhotoActionButtons(),
                            const SizedBox(height: 16),

                            // Section Title
                            const Text(
                              'Sample Identification & Selection',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select any number of sample captures for multi-sample aggregation.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.navyMuted,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Sample Cards (Only identification and image, NO analytical counts/metrics - Requirement 4)
                            ..._allSamples.map((sample) {
                              final isSelected =
                                  _selectedSampleIds.contains(sample.sampleId);
                              return _buildSampleCard(sample, isSelected);
                            }),
                          ],
                        ),
                      ),
          ),
          // Bottom Summary Bar (Requirement 5: shows sample count & summary, NO analytical totals)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          '${_selectedSampleIds.length} sample${_selectedSampleIds.length == 1 ? '' : 's'} selected',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          '${_selectedSampleIds.length} of ${_allSamples.length} available',
                          style: TextStyle(
                            fontSize: 11,
                            color: _selectedSampleIds.isEmpty
                                ? AppColors.rejectRed
                                : AppColors.tealDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: _selectedSampleIds.isNotEmpty
                        ? _proceedToCapture
                        : null,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue to Capture'),
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

  Widget _buildCaptureGuidanceCard() {
    return Container(
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
              Icon(Icons.info_outline, size: 16, color: AppColors.tealDark),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Prototype Capture Guidance',
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
          _guidanceItem('Arrange onions separately without overlap.'),
          _guidanceItem('Use consistent lighting.'),
          _guidanceItem('Position the camera as vertically as practical.'),
          _guidanceItem('Keep the tray/reference marker visible.'),
          _guidanceItem('Avoid blur and glare.'),
        ],
      ),
    );
  }

  Widget _guidanceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.navyText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoActionButtons() {
    return Row(
      children: [
        // Take Photo (Simulated Camera)
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              side: const BorderSide(color: AppColors.tealPrimary),
            ),
            onPressed: _takeSimulatedPhoto,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: AppColors.tealPrimary, size: 20),
                SizedBox(height: 4),
                Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
                Text(
                  'Simulated camera',
                  style: TextStyle(fontSize: 9.5, color: AppColors.tealDark),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Choose from Gallery (5 Predefined Images)
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              side: const BorderSide(color: AppColors.navyMuted),
            ),
            onPressed: _openGalleryPicker,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library, color: AppColors.navyDark, size: 20),
                SizedBox(height: 4),
                Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
                Text(
                  '5 predefined images',
                  style: TextStyle(fontSize: 9.5, color: AppColors.navyMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSampleCard(SampleModel sample, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.tealLight.withValues(alpha: 0.3)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.tealPrimary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
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
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Thumbnail with Tap to Enlarge (Requirement 6: BoxFit.contain, responsive, tap to enlarge)
                GestureDetector(
                  onTap: () {
                    ImageViewerDialog.show(
                      context,
                      imagePath: sample.rawImage,
                      title: _neutralTitle(sample),
                      subtitle:
                          'Sample Photographic Capture (Tap anywhere to zoom)',
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceMuted,
                          child: Image.asset(
                            sample.rawImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: AppColors.navyMuted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(Icons.zoom_in,
                              size: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Details (Only sample ID, sample name, description - NO analytical numbers!)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _neutralTitle(sample),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Prepared demonstration tray for inspection',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.navyMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Selection Checkbox
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.tealPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
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
