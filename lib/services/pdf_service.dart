import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/inspection_model.dart';

class PdfService {
  /// Generates a PDF Quality Assessment Report for the inspection.
  static Future<Uint8List> generateReportPdf(InspectionModel inspection) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(inspection.timestamp);
    final agg = inspection.aggregatedResult;
    final rules = inspection.rulesUsed;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DIGITAL QUALITY ASSESSMENT REPORT',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'SIH26031: Mobile Computer Vision & Metric Calibration for Offline Onion Grading',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.blueGrey700),
                  ),
                  pw.Text(
                    'Prototype Field Assaying System • Prepared Demo Results',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  'PROTOTYPE DEMO',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.blueGrey200),
          pw.SizedBox(height: 8),

          // Lot & Inspection Details Table
          pw.Text(
            '1. INSPECTION & LOT REGISTRATION',
            style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _buildTableRow('Inspection ID', inspection.inspectionId,
                  'Date / Time', formattedDate),
              _buildTableRow('Lot ID', inspection.lotId, 'Farmer Name',
                  inspection.farmerName),
              _buildTableRow('Procurement Centre', inspection.procurementCentre,
                  'Inspector ID', inspection.inspectorId),
              _buildTableRow('Onion Variety', inspection.onionVariety,
                  'Lot Quantity', inspection.lotQuantity),
            ],
          ),
          pw.SizedBox(height: 12),

          // Sampling Overview
          pw.Text(
            '2. SAMPLING & METRIC MEASUREMENTS',
            style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _buildTableRow(
                'Samples Selected',
                '${inspection.selectedSampleIds.length} (${inspection.selectedSampleIds.join(", ")})',
                'Total Onions Analyzed',
                '${agg.totalOnions} onions',
              ),
              _buildTableRow(
                'Average Diameter',
                '${agg.avgDiameter.toStringAsFixed(1)} mm (Demo Estimate)',
                'Diameter Range (Min-Max)',
                '${agg.minDiameter} mm - ${agg.maxDiameter} mm',
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Quality Composition Breakdown Table
          pw.Text(
            '3. AGGREGATED QUALITY COMPOSITION',
            style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
                children: [
                  _headerCell('Quality Category'),
                  _headerCell('Count'),
                  _headerCell('Percentage'),
                  _headerCell('Grade A Limit'),
                  _headerCell('URS Limit'),
                ],
              ),
              _dataRow('Healthy Onions', '${agg.totalHealthy}',
                  '${agg.healthyPercent.toStringAsFixed(1)}%', '—', '—'),
              _dataRow(
                  'Surface Defects',
                  '${agg.totalSurfaceDefect}',
                  '${agg.surfaceDefectPercent.toStringAsFixed(1)}%',
                  '${rules.surfaceDefectGradeAMax}%',
                  '${rules.surfaceDefectUrsMax}%'),
              _dataRow(
                  'Severe Visible Defect',
                  '${agg.totalSevereDefect}',
                  '${agg.severeDefectPercent.toStringAsFixed(1)}%',
                  '${rules.rotGradeAMax}%',
                  '${rules.rotUrsMax}%'),
              _dataRow(
                  'Sprouting',
                  '${agg.totalSprouting}',
                  '${agg.sproutingPercent.toStringAsFixed(1)}%',
                  '${rules.sproutingGradeAMax}%',
                  '${rules.sproutingUrsMax}%'),
              _dataRow(
                  'Undersized Onions',
                  '${agg.totalUndersized}',
                  '${agg.undersizedPercent.toStringAsFixed(1)}%',
                  '${rules.undersizedGradeAMax}%',
                  '${rules.undersizedUrsMax}%'),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _headerCell('TOTAL AGGREGATE'),
                  _headerCell('${agg.totalOnions}'),
                  _headerCell('100.0%'),
                  _headerCell(''),
                  _headerCell(''),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Final Assessment & Human Review Section
          pw.Text(
            '4. FINAL GRADING ASSESSMENT',
            style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'AI Engine Observation: ${inspection.engineResult}',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      'FINAL DECISION: ${inspection.finalResult.toUpperCase()}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: inspection.finalResult
                                .toLowerCase()
                                .contains('grade a')
                            ? PdfColors.green800
                            : (inspection.finalResult
                                    .toLowerCase()
                                    .contains('urs')
                                ? PdfColors.amber800
                                : PdfColors.red800),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Engine Explanations:',
                  style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 8),
                ),
                ...inspection.engineExplanations.map((exp) =>
                    pw.Text('• $exp', style: const pw.TextStyle(fontSize: 8))),
                if (inspection.humanReview != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Inspector Review Action: ${inspection.humanReview!.action.toUpperCase()} by ${inspection.humanReview!.inspectorId}',
                    style: const pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 8),
                  ),
                  if (inspection.humanReview!.reason != null)
                    pw.Text('Reason: ${inspection.humanReview!.reason}',
                        style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    'Internal Verification Performed: ${inspection.humanReview!.internalVerificationPerformed ? "YES - ${inspection.humanReview!.internalVerificationResult}" : "NO"}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (inspection.humanReview!.internalVerificationNotes != null)
                    pw.Text(
                        'Physical Check Notes: ${inspection.humanReview!.internalVerificationNotes}',
                        style: const pw.TextStyle(fontSize: 8)),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Disclaimers & Signatures
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STATUTORY & TECHNICAL DISCLAIMER',
                  style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 7,
                      color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '1. This report is produced by a Smart India Hackathon 2026 prototype demonstrating an AI-assisted field inspection workflow using precomputed results.\n'
                  '2. It is NOT a certified government grading document and does not replace official CWC laboratory assay.\n'
                  '3. Internal condition cannot be established from RGB camera photography alone.\n'
                  '4. Metric calibration values are demonstration estimates only.',
                  style: const pw.TextStyle(
                      fontSize: 6.5, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text('Farmer / Representative',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text('Inspecting Officer (${inspection.inspectorId})',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(
      String label1, String val1, String label2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label1,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey700)),
              pw.Text(val1,
                  style: const pw.TextStyle(
                      fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label2,
                  style: const pw.TextStyle(
                      fontSize: 7, color: PdfColors.grey700)),
              pw.Text(val2,
                  style: const pw.TextStyle(
                      fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800),
      ),
    );
  }

  static pw.TableRow _dataRow(
      String cat, String count, String pct, String grA, String urs) {
    return pw.TableRow(
      children: [
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text(cat, style: const pw.TextStyle(fontSize: 8))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text(count, style: const pw.TextStyle(fontSize: 8))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text(pct,
                style: const pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text(grA, style: const pw.TextStyle(fontSize: 8))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: pw.Text(urs, style: const pw.TextStyle(fontSize: 8))),
      ],
    );
  }

  static Future<void> printOrSharePdf(InspectionModel inspection) async {
    final bytes = await generateReportPdf(inspection);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Onion_Assay_${inspection.inspectionId}.pdf',
    );
  }
}
