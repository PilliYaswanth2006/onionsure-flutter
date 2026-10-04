import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';
import '../repositories/inspection_repository.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/quality_badge.dart';
import 'final_report_screen.dart';

class HistoryScreen extends StatefulWidget {
  final InspectionRepository inspectionRepository;

  const HistoryScreen({
    super.key,
    required this.inspectionRepository,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<InspectionModel> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await widget.inspectionRepository.getAllInspections();
    if (mounted) {
      setState(() {
        _inspections = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inspection History'),
        actions: [
          if (_inspections.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.rejectRed),
              tooltip: 'Clear History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Inspections?'),
                    content: const Text('This will delete locally saved offline inspection records.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejectRed),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.inspectionRepository.clearAll();
                  _loadHistory();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspections.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 48, color: AppColors.navyMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No Inspections Recorded Yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Complete a new inspection flow to store records offline.',
                          style: TextStyle(fontSize: 12, color: AppColors.navyMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Return Home'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inspections.length,
                  itemBuilder: (context, index) {
                    final insp = _inspections[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                insp.inspectionId,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark,
                                ),
                              ),
                              QualityBadge(label: insp.finalResult),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Lot: ${insp.lotId} • Farmer: ${insp.farmerName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.navyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Date: ${dateFormat.format(insp.timestamp)} • ${insp.selectedSampleIds.length} samples (${insp.aggregatedResult.totalOnions} onions)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.navyMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  insp.syncStatus,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tealDark,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                icon: const Icon(Icons.picture_as_pdf, size: 16),
                                label: const Text('PDF', style: TextStyle(fontSize: 12)),
                                onPressed: () => PdfService.printOrSharePdf(insp),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 34),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FinalReportScreen(
                                        inspectionRepository: widget.inspectionRepository,
                                        inspection: insp,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
