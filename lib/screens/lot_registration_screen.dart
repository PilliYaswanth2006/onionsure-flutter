import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/progress_stepper.dart';
import 'guided_sampling_screen.dart';

class LotRegistrationScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;

  const LotRegistrationScreen({
    super.key,
    required this.inspectionRepository,
  });

  @override
  State<LotRegistrationScreen> createState() => _LotRegistrationScreenState();
}

class _LotRegistrationScreenState extends State<LotRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _inspectionIdCtrl;
  late TextEditingController _lotIdCtrl;
  late TextEditingController _farmerNameCtrl;
  late TextEditingController _centreCtrl;
  late TextEditingController _inspectorIdCtrl;
  late TextEditingController _varietyCtrl;
  late TextEditingController _quantityCtrl;

  @override
  void initState() {
    super.initState();
    final timestamp = DateFormat('yyMMdd-HHmm').format(DateTime.now());
    _inspectionIdCtrl = TextEditingController(text: 'INSP-$timestamp');
    _lotIdCtrl = TextEditingController(text: AppConstants.defaultLotId);
    _farmerNameCtrl = TextEditingController(text: AppConstants.defaultFarmer);
    _centreCtrl = TextEditingController(text: AppConstants.defaultCentre);
    _inspectorIdCtrl =
        TextEditingController(text: AppConstants.defaultInspector);
    _varietyCtrl = TextEditingController(text: AppConstants.defaultVariety);
    _quantityCtrl = TextEditingController(text: AppConstants.defaultQuantity);
  }

  @override
  void dispose() {
    _inspectionIdCtrl.dispose();
    _lotIdCtrl.dispose();
    _farmerNameCtrl.dispose();
    _centreCtrl.dispose();
    _inspectorIdCtrl.dispose();
    _varietyCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _proceedToSampling() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GuidedSamplingScreen(
            inspectionRepository: widget.inspectionRepository,
            inspectionId: _inspectionIdCtrl.text.trim(),
            lotId: _lotIdCtrl.text.trim(),
            farmerName: _farmerNameCtrl.text.trim(),
            procurementCentre: _centreCtrl.text.trim(),
            inspectorId: _inspectorIdCtrl.text.trim(),
            onionVariety: _varietyCtrl.text.trim(),
            lotQuantity: _quantityCtrl.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lot Registration'),
      ),
      body: Column(
        children: [
          const ProgressStepper(currentStep: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceMuted,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1 of 5 · Lot Registration',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Verify the lot, producer, procurement centre and inspector details before sampling.',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group 1: Produce Details
                    _buildSectionHeader('Produce Details'),
                    _buildGroupCard([
                      _buildField(
                        label: 'Lot ID',
                        controller: _lotIdCtrl,
                        icon: Icons.tag,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Onion Variety',
                        controller: _varietyCtrl,
                        icon: Icons.grain,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Lot Quantity',
                        controller: _quantityCtrl,
                        icon: Icons.scale,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Group 2: Farmer & Location
                    _buildSectionHeader('Farmer & Location'),
                    _buildGroupCard([
                      _buildField(
                        label: 'Farmer / Producer Name',
                        controller: _farmerNameCtrl,
                        icon: Icons.person_outline,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Procurement Centre / APMC',
                        controller: _centreCtrl,
                        icon: Icons.location_on_outlined,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Group 3: Assay Credentials
                    _buildSectionHeader('Assay Credentials'),
                    _buildGroupCard([
                      _buildField(
                        label: 'Inspection ID',
                        controller: _inspectionIdCtrl,
                        icon: Icons.qr_code,
                        helperText: 'Auto-generated',
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Inspector ID',
                        controller: _inspectorIdCtrl,
                        icon: Icons.badge_outlined,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _proceedToSampling,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Sampling',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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

  Widget _buildGroupCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 11, color: AppColors.navyMuted),
        prefixIcon: Icon(icon, size: 20, color: AppColors.navyMuted),
      ),
    );
  }
}
