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
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  List<InspectionModel> get _filteredInspections {
    return _inspections.where((insp) {
      if (_selectedFilter != 'All' && insp.finalResult != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchId = insp.inspectionId.toLowerCase().contains(q);
        final matchLot = insp.lotId.toLowerCase().contains(q);
        final matchFarmer = insp.farmerName.toLowerCase().contains(q);
        final matchCentre = insp.procurementCentre.toLowerCase().contains(q);
        if (!matchId && !matchLot && !matchFarmer && !matchCentre) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final filtered = _filteredInspections;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Inspection History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${_inspections.length} inspection${_inspections.length == 1 ? '' : 's'} recorded',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.navyMuted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
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
                    content: const Text(
                        'This will delete locally saved offline inspection records.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rejectRed),
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
                        const Icon(Icons.history,
                            size: 48, color: AppColors.navyMuted),
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
                          style: TextStyle(
                              fontSize: 12, color: AppColors.navyMuted),
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
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search inspections...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                      ),
                    ),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Row(
                        children:
                            ['All', 'Grade A', 'URS', 'Reject'].map((filter) {
                          final isSel = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSel,
                              selectedColor: AppColors.tealPrimary,
                              labelStyle: TextStyle(
                                color:
                                    isSel ? Colors.white : AppColors.navyDark,
                                fontSize: 11.5,
                                fontWeight:
                                    isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedFilter = filter),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // List of filtered inspections
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching inspections found',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.navyMuted),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final insp = filtered[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              insp.inspectionId,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navyDark,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                                        '${dateFormat.format(insp.timestamp)} • ${insp.selectedSampleIds.length} samples (${insp.aggregatedResult.totalOnions} onions)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.navyMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.healthyGreen
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: AppColors.healthyGreen
                                                      .withValues(alpha: 0.3)),
                                            ),
                                            child: const Text(
                                              'Stored Locally',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.healthyGreen,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                ),
                                                icon: const Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 15),
                                                label: const Text('PDF',
                                                    style: TextStyle(
                                                        fontSize: 11.5)),
                                                onPressed: () =>
                                                    PdfService.printOrSharePdf(
                                                        insp),
                                              ),
                                              const SizedBox(width: 4),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(0, 32),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FinalReportScreen(
                                                        inspectionRepository: widget
                                                            .inspectionRepository,
                                                        inspection: insp,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Report',
                                                        style: TextStyle(
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.arrow_forward,
                                                        size: 13),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
