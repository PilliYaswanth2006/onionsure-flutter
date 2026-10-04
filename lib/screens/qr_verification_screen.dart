import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/inspection_model.dart';
import '../services/qr_service.dart';
import '../utils/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/quality_badge.dart';

class QrVerificationScreen extends StatelessWidget {
  final InspectionModel inspection;

  const QrVerificationScreen({
    super.key,
    required this.inspection,
  });

  @override
  Widget build(BuildContext context) {
    final payload = QrService.generateVerificationPayload(inspection);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(inspection.timestamp);
    final agg = inspection.aggregatedResult;
    final rules = inspection.rulesUsed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inspection QR Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.healthyGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color:
                              AppColors.healthyGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: AppColors.healthyGreen),
                        SizedBox(width: 6),
                        Text(
                          '✓ Verification Ready',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.healthyGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.navyDark,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'OFFLINE INSPECTION PASSPORT',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.tealDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: inspection.inspectionId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Inspection ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            inspection.inspectionId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy,
                              size: 14, color: AppColors.tealDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Honest QR notice
            const DisclaimerBanner.info(
              message:
                  'The QR code serves as an offline record verification mechanism. It does not cryptographically seal the physical lot or substitute official CWC assay certification.',
            ),
            const SizedBox(height: 16),

            // Verification Data Card
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Verified Inspection Record',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                      QualityBadge(label: inspection.finalResult),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildDataRow('Inspection ID', inspection.inspectionId),
                  _buildDataRow('Lot ID', inspection.lotId),
                  _buildDataRow('Farmer Name', inspection.farmerName),
                  _buildDataRow(
                      'Procurement Centre', inspection.procurementCentre),
                  _buildDataRow('Date & Time', formattedDate),
                  _buildDataRow('Sample Count',
                      '${inspection.selectedSampleIds.length} captures'),
                  _buildDataRow(
                      'Total Onions Assayed', '${agg.totalOnions} onions'),
                  _buildDataRow('Applied Rules',
                      'Nashik Red (${rules.diameterMinMm}-${rules.diameterMaxMm}mm)'),
                  _buildDataRow('Verification Status', 'VALID OFFLINE RECORD',
                      statusColor: AppColors.healthyGreen),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String val, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.navyMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor ?? AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
