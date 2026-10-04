import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep; // 1 to 5
  final List<String> steps;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    this.steps = const [
      'Lot',
      'Sample',
      'Capture',
      'Analysis',
      'Report',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevStep = (index ~/ 2) + 1;
            final isCompleted = currentStep > prevStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? AppColors.tealPrimary : AppColors.border,
              ),
            );
          }

          final stepNum = (index ~/ 2) + 1;
          final isCompleted = currentStep > stepNum;
          final isCurrent = currentStep == stepNum;

          Color bg = AppColors.surfaceMuted;
          Color text = AppColors.navyMuted;
          Color border = AppColors.borderSubtle;

          if (isCompleted) {
            bg = AppColors.tealPrimary;
            text = Colors.white;
            border = AppColors.tealPrimary;
          } else if (isCurrent) {
            bg = AppColors.tealLight;
            text = AppColors.tealDark;
            border = AppColors.tealPrimary;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: isCurrent ? 1.5 : 1),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text(
                        '$stepNum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: text,
                        ),
                      ),
              ),
              const SizedBox(height: 3),
              Text(
                steps[stepNum - 1],
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppColors.tealDark : AppColors.navyMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
