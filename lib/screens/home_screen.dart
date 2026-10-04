import 'package:flutter/material.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'grading_config_screen.dart';
import 'history_screen.dart';
import 'lot_registration_screen.dart';

class HomeScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;

  const HomeScreen({
    super.key,
    required this.inspectionRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pastInspectionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistoryCount();
  }

  Future<void> _loadHistoryCount() async {
    final list = await widget.inspectionRepository.getAllInspections();
    if (mounted) {
      setState(() {
        _pastInspectionCount = list.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Field Assaying Unit'),
        actions: [
          // Offline Badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.healthyGreenBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.healthyGreenBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 12, color: AppColors.healthyGreen),
                SizedBox(width: 4),
                Text(
                  'OFFLINE MODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.healthyGreen,
                  ),
                ),
              ],
            ),
          ),
          // Demo Mode Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningAmberBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warningAmberBorder),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.warningAmber,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ministry / Gov Assay Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.tealLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppColors.tealPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Onion Quality Assay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Problem Statement: ${AppConstants.problemStatementId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tealDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '"${AppConstants.projectTitle}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppConstants.problemDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.navyMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prototype Honesty Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: AppColors.navyMuted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prototype field-assaying model using precomputed demonstration results from samples.json. Demonstrates full guided sampling, multi-sample aggregation, and dynamic rule-based grading.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.navyMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Primary Actions
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 12),

              // Start New Inspection (Primary)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LotRegistrationScreen(
                        inspectionRepository: widget.inspectionRepository,
                      ),
                    ),
                  ).then((_) => _loadHistoryCount());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 10),
                    Text('New Inspection'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Inspection History (Secondary)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                        inspectionRepository: widget.inspectionRepository,
                      ),
                    ),
                  ).then((_) => _loadHistoryCount());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _pastInspectionCount > 0
                          ? 'Inspection History ($_pastInspectionCount records)'
                          : 'Inspection History',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic Grading Rules Configuration
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GradingConfigScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune, size: 20),
                    SizedBox(width: 10),
                    Text('Configure Grading Rules'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Quick Flow Guide
              const Text(
                'Standard Field Workflow',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 8),
              _flowStep('1', 'Lot Registration', 'Capture farmer and procurement lot metadata'),
              _flowStep('2', 'Guided Sampling', 'Select representative sample captures (S01-S05)'),
              _flowStep('3', 'Smart Capture', 'Verify framing, lighting, and reference visibility'),
              _flowStep('4', 'Prepared CV Analysis', 'Extract defect distribution & diameter counts'),
              _flowStep('5', 'Multi-sample Aggregation', 'Strict count aggregation across all samples'),
              _flowStep('6', 'Grading & Review', 'Dynamic rule matching + physical verification audit'),
              _flowStep('7', 'Digital Certificate', 'Offline PDF generation & QR verification'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flowStep(String num, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.tealDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyText,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.navyMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
