import 'package:flutter/material.dart';
import '../repositories/inspection_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/app_tutorial_dialog.dart';
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

  void _showBadgeDialog(String title, String explanation) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark)),
        content: Text(explanation,
            style: const TextStyle(fontSize: 13, color: AppColors.navyText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.eco,
                color: AppColors.tealPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/images/onionsure_wordmark.png',
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => const Text(
                'OnionSure',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Tap-to-explain Offline Badge
          GestureDetector(
            onTap: () => _showBadgeDialog(
              'OFFLINE Mode',
              'Local demo operations are designed to work without a network connection.',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.healthyGreenBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.healthyGreenBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off,
                      size: 10, color: AppColors.healthyGreen),
                  SizedBox(width: 3),
                  Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.healthyGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tap-to-explain Demo Badge
          GestureDetector(
            onTap: () => _showBadgeDialog(
              'DEMO Mode',
              'Results are prepared demonstration data, not live AI predictions.',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warningAmberBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.warningAmberBorder),
              ),
              child: const Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warningAmber,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen 1: Introduction Heading
              const Text(
                'OnionSure — Onion Quality Assessment Prototype',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Demonstrate an onion inspection workflow using prepared sample results, recorded observations, diameter estimates, and transparent grading rules.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.navyText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Clear Prototype Disclosure
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 15,
                      color: AppColors.tealDark,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DEMO: Results use prepared demonstration data. Diameter values are estimates pending validated calibration. This is not an official grading certificate.',
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
              const SizedBox(height: 16),

              // Dominant Primary Action: New Inspection
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => LotRegistrationScreen(
                            inspectionRepository: widget.inspectionRepository,
                          ),
                        ),
                      )
                      .then((_) => _loadHistoryCount());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'New Inspection',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Actions Row: History and Grading Rules
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => HistoryScreen(
                                  inspectionRepository:
                                      widget.inspectionRepository,
                                ),
                              ),
                            )
                            .then((_) => _loadHistoryCount());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history, size: 16),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _pastInspectionCount > 0
                                  ? 'History ($_pastInspectionCount)'
                                  : 'History',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                      ),
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
                          Icon(Icons.tune, size: 16),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Grading Rules',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Replayable App Tutorial Trigger
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tealBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => AppTutorialDialog.show(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined,
                              color: AppColors.tealPrimary, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Tutorial',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Learn the workflow or replay the walkthrough.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.navyMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppColors.navyMuted, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Section 5: Inspection Workflow Preview
              Container(
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
                    const Text(
                      'Inspection Workflow',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'From lot registration to reviewable quality reporting.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.navyMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 5-stage preview
                    Row(
                      children: [
                        _buildWorkflowNode('1. Lot', Icons.assignment_outlined),
                        _buildWorkflowArrow(),
                        _buildWorkflowNode(
                            '2. Sample', Icons.grid_view_outlined),
                        _buildWorkflowArrow(),
                        _buildWorkflowNode(
                            '3. Capture', Icons.camera_alt_outlined),
                        _buildWorkflowArrow(),
                        _buildWorkflowNode(
                            '4. Analysis', Icons.analytics_outlined),
                        _buildWorkflowArrow(),
                        _buildWorkflowNode(
                            '5. Report', Icons.description_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Section 6: What the Assessment Evaluates
              Container(
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
                    const Text(
                      'What the Assessment Evaluates',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildEvalBadge('Healthy', AppColors.healthyGreen,
                            AppColors.healthyGreenBg),
                        _buildEvalBadge('Surface Defect', AppColors.warningAmber,
                            AppColors.warningAmberBg),
                        _buildEvalBadge('Severe Visible Defect',
                            AppColors.rejectRed, AppColors.rejectRedBg),
                        _buildEvalBadge('Sprouting', AppColors.warningAmber,
                            AppColors.warningAmberBg),
                        _buildEvalBadge('Undersized', AppColors.infoBlue,
                            AppColors.infoBlueBg),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowNode(String label, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: 14, color: AppColors.tealDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.navyText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Icon(Icons.arrow_forward_ios, size: 8, color: AppColors.navyMuted),
    );
  }

  Widget _buildEvalBadge(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
