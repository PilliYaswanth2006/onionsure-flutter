import 'package:flutter/material.dart';
import 'repositories/inspection_repository.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final inspectionRepository = InspectionRepository();

  runApp(OnionAssayApp(inspectionRepository: inspectionRepository));
}

class OnionAssayApp extends StatelessWidget {
  final InspectionRepository inspectionRepository;

  const OnionAssayApp({
    super.key,
    required this.inspectionRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onion Quality Assay (SIH26031)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(inspectionRepository: inspectionRepository),
    );
  }
}
