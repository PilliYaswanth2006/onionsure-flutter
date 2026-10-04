class AppConstants {
  static const String problemStatementId = 'SIH26031';
  static const String projectTitle = 'Mobile Computer Vision & Metric Calibration for Offline Onion Grading';
  static const String problemDescription =
      'Quality assessment and grading of onions are often subjective and vary across procurement centers, resulting in disputes and inconsistencies.';

  // Disclaimers & Honesty notices
  static const String preparedResultNotice = 'Prepared CV Result — Prototype Demo';
  static const String demoMeasurementNotice = 'Demo Measurement: Production deployment requires validated metric calibration.';
  static const String internalRotNotice =
      'Internal condition cannot be established from ordinary RGB imagery alone. Field assay requires physical verification.';
  static const String samplingDisclaimer =
      'Prototype sampling workflow. Demonstrates multi-sample aggregation logic, not an official statutory protocol.';
  static const String honestPrototypeDisclaimer =
      'This prototype demonstrates an AI-assisted field inspection workflow using precomputed results. It is NOT a production-certified government grading system or official CWC assay.';

  // Demo Registration Defaults
  static const String defaultLotId = 'LOT-2026-001';
  static const String defaultFarmer = 'Ramesh Patil';
  static const String defaultCentre = 'Lasalgaon APMC (Nashik)';
  static const String defaultInspector = 'INS-MH-42';
  static const String defaultVariety = 'Red Onion (Nashik Red)';
  static const String defaultQuantity = '850 kg';
}
