import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih_onion_grading/main.dart';
import 'package:sih_onion_grading/repositories/inspection_repository.dart';
import 'package:sih_onion_grading/screens/guided_sampling_screen.dart';
import 'package:sih_onion_grading/screens/lot_registration_screen.dart';
import 'package:sih_onion_grading/screens/smart_capture_screen.dart';
import 'package:sih_onion_grading/services/dataset_service.dart';
import 'package:sih_onion_grading/utils/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnionSure Widget & Responsiveness Tests', () {
    testWidgets('App renders Home screen with branding and primary actions',
        (WidgetTester tester) async {
      final repo = InspectionRepository();
      await tester.pumpWidget(OnionAssayApp(inspectionRepository: repo));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsWidgets);
      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.text('DEMO'), findsOneWidget);
      expect(find.text('New Inspection'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Grading Rules'), findsOneWidget);
    });

    testWidgets('Home screen renders without overflow on narrow 320px viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = InspectionRepository();
      await tester.pumpWidget(OnionAssayApp(inspectionRepository: repo));
      await tester.pumpAndSettle();

      expect(find.text('New Inspection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'LotRegistrationScreen renders without overflow on 320px and 360px viewports',
        (WidgetTester tester) async {
      for (final width in [320.0, 360.0]) {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;

        final repo = InspectionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: LotRegistrationScreen(inspectionRepository: repo),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lot Registration'), findsOneWidget);
        expect(find.text('Produce Details'), findsOneWidget);
        expect(find.text('Farmer & Location'), findsOneWidget);
        expect(find.text('Assay Credentials'), findsOneWidget);
        expect(find.text('Start Sampling'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
        'GuidedSamplingScreen renders without overflow on 320px viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final samples = await DatasetService().loadSamples();
      final repo = InspectionRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: GuidedSamplingScreen(
            inspectionRepository: repo,
            inspectionId: 'INSP-TEST',
            lotId: 'LOT-TEST',
            farmerName: 'Farmer Test',
            procurementCentre: 'Centre Test',
            inspectorId: 'INS-01',
            onionVariety: 'Red Onion',
            lotQuantity: '500 kg',
            initialSamples: samples,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sampling'), findsOneWidget);
      expect(find.text('Prototype Capture Guidance'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        // ignore: avoid_print
        print('OVERFLOW ERROR DETAILS:\n$err');
      }
      expect(err, isNull);
    });

    testWidgets(
        'SmartCaptureScreen renders guidance and simulated checks without overflow on 320px viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final samples = await DatasetService().loadSamples();
      final repo = InspectionRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SmartCaptureScreen(
            inspectionRepository: repo,
            inspectionId: 'INSP-TEST',
            lotId: 'LOT-TEST',
            farmerName: 'Farmer Test',
            procurementCentre: 'Centre Test',
            inspectorId: 'INS-01',
            onionVariety: 'Red Onion',
            lotQuantity: '500 kg',
            selectedSamples: samples,
            currentSampleIndex: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prototype Capture Guidance'), findsOneWidget);
      expect(find.text('Simulated Capture Checks (Demo Indicators)'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
