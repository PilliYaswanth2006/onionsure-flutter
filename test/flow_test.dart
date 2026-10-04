import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih_onion_grading/main.dart';
import 'package:sih_onion_grading/repositories/inspection_repository.dart';

void main() {
  testWidgets(
      'End-to-End User Flow Test: Launch -> Lot Registration -> Sampling -> Analysis -> Aggregation -> Review -> Report',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = InspectionRepository();
    await repo.clearAll();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App
    await tester.pumpWidget(OnionAssayApp(inspectionRepository: repo));
    await tester.pumpAndSettle();

    // Verify Home Screen elements
    expect(find.byType(Image), findsWidgets);
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.text('New Inspection'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Grading Rules'), findsOneWidget);

    // 2. Tap New Inspection
    await tester.tap(find.text('New Inspection'));
    await tester.pumpAndSettle();

    // Verify Lot Registration Screen
    expect(find.text('Lot Registration'), findsOneWidget);
    expect(find.text('Start Sampling'), findsOneWidget);

    // 3. Tap Start Sampling (with demo defaults)
    await tester.tap(find.text('Start Sampling'));
    await tester.pumpAndSettle();

    // Verify Guided Sampling Screen
    expect(find.text('Sampling'), findsOneWidget);
    expect(
        find.text(
            'Select any number of sample captures for multi-sample aggregation.'),
        findsOneWidget);
    // S01, S03, S04 are selected by default demo state (3 of 5 samples)
    expect(find.text('Selected: 3 of 5 samples'), findsOneWidget);

    // 4. Tap Continue to proceed to Smart Capture
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify Smart Capture Screen (Sample 1 of 3)
    expect(find.text('Smart Capture (1 of 3)'), findsOneWidget);
    expect(find.text('Prototype Capture Guidance'), findsOneWidget);
    expect(find.text('Simulated Capture Checks (Demo Indicators)'),
        findsOneWidget);
    expect(find.text('Use This Sample (1 of 3)'), findsOneWidget);

    // 5. Tap Use This Sample (1 of 3) -> AI Analysis
    final useBtn1 = find.text('Use This Sample (1 of 3)');
    await tester.ensureVisible(useBtn1);
    await tester.tap(useBtn1);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify AI Analysis Screen
    expect(find.widgetWithText(AppBar, 'Analysis'), findsOneWidget);
    expect(find.text('Prepared Demo Results'), findsOneWidget);
    expect(find.text('Total: 26 Onions'), findsOneWidget);
    expect(find.text('Severe Visible Defect'), findsOneWidget);
    expect(find.text('Technical Measurements & Calibration'), findsOneWidget);
    expect(find.text('Analyze Next Sample (2 of 3)'), findsOneWidget);

    // 6. Tap Next Sample -> Smart Capture (2 of 3)
    final nextBtn1 = find.text('Analyze Next Sample (2 of 3)');
    await tester.ensureVisible(nextBtn1);
    await tester.tap(nextBtn1);
    await tester.pumpAndSettle();
    expect(find.text('Smart Capture (2 of 3)'), findsOneWidget);

    // Tap Use This Sample (2 of 3) -> AI Analysis
    final useBtn2 = find.text('Use This Sample (2 of 3)');
    await tester.ensureVisible(useBtn2);
    await tester.tap(useBtn2);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Tap Next Sample -> Smart Capture (3 of 3)
    expect(find.text('Analyze Next Sample (3 of 3)'), findsOneWidget);
    final nextBtn2 = find.text('Analyze Next Sample (3 of 3)');
    await tester.ensureVisible(nextBtn2);
    await tester.tap(nextBtn2);
    await tester.pumpAndSettle();
    expect(find.text('Smart Capture (3 of 3)'), findsOneWidget);

    // Tap Use This Sample (3 of 3) -> AI Analysis
    final useBtn3 = find.text('Use This Sample (3 of 3)');
    await tester.ensureVisible(useBtn3);
    await tester.tap(useBtn3);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Final Sample Analysis has Proceed to Aggregation button
    expect(find.text('Proceed to Multi-Sample Aggregation'), findsOneWidget);

    // 7. Proceed to Multi-Sample Aggregation
    final aggBtn = find.text('Proceed to Multi-Sample Aggregation');
    await tester.ensureVisible(aggBtn);
    await tester.tap(aggBtn);
    await tester.pumpAndSettle();

    // Verify Aggregation Screen
    expect(find.text('Multi-Sample Aggregation'), findsOneWidget);
    expect(find.text('TOTAL AGGREGATED'), findsOneWidget);
    expect(find.text('78 onions'), findsOneWidget);
    expect(find.text('Severe Visible Defect'), findsOneWidget);
    expect(find.text('Validation passed: Category counts equal total onions'),
        findsOneWidget);
    expect(find.text('Apply Grading Rules & Review'), findsOneWidget);

    // 8. Proceed to Grading Decision & Review
    final applyBtn = find.text('Apply Grading Rules & Review');
    await tester.ensureVisible(applyBtn);
    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    // Verify Human Review Screen
    expect(find.text('Grading Review'), findsOneWidget);
    expect(find.text('Final Assessment'), findsOneWidget);
    expect(find.text('Physical Internal Quality Verification'), findsOneWidget);
    expect(find.text('Confirm Result (Inspector Review: CONFIRMED)'),
        findsOneWidget);
    expect(find.text('Correct / Override'), findsOneWidget);
    expect(find.text('Reject Lot'), findsOneWidget);

    // 9. Inspector Accepts Result
    final confirmBtn =
        find.text('Confirm Result (Inspector Review: CONFIRMED)');
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify Final Report Screen
    expect(find.widgetWithText(AppBar, 'Report'), findsOneWidget);
    expect(find.text('DIGITAL QUALITY REPORT'), findsOneWidget);
    expect(find.text('Generate Quality Assessment Report'), findsOneWidget);
    expect(find.text('Open QR Verification'), findsOneWidget);

    // 10. Open QR Verification Screen
    final qrBtn = find.text('Open QR Verification');
    await tester.ensureVisible(qrBtn);
    await tester.tap(qrBtn);
    await tester.pumpAndSettle();

    // Verify QR Verification Screen
    expect(find.text('Certificate QR Verification'), findsOneWidget);
    expect(find.text('OFFLINE INSPECTION PASSPORT'), findsOneWidget);
    expect(find.text('VALID OFFLINE RECORD'), findsOneWidget);

    // Tap Back to Report
    final backBtn = find.text('Back to Report');
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // 11. Return to Home
    final returnHomeBtn = find.text('Return to Home');
    await tester.ensureVisible(returnHomeBtn);
    await tester.tap(returnHomeBtn);
    await tester.pumpAndSettle();

    // Verify Back on Home Screen and history count reflects 1 record
    expect(find.text('History (1)'), findsOneWidget);

    // 12. Open History Screen
    await tester.tap(find.text('History (1)'));
    await tester.pumpAndSettle();

    // Verify entry in history
    expect(find.text('Inspection History'), findsOneWidget);
    expect(find.textContaining('Lot: LOT-2026-001'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    // Reopen report from History
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Report'), findsOneWidget);
    expect(find.text('DIGITAL QUALITY REPORT'), findsOneWidget);
  });
}
