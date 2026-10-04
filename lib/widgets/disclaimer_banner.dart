import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DisclaimerBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const DisclaimerBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = AppColors.tealLight,
    this.textColor = AppColors.tealDark,
    this.borderColor = AppColors.tealBorder,
  });

  const DisclaimerBanner.warning({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
    this.backgroundColor = AppColors.warningAmberBg,
    this.textColor = AppColors.warningAmber,
    this.borderColor = AppColors.warningAmberBorder,
  });

  const DisclaimerBanner.info({
    super.key,
    required this.message,
    this.icon = Icons.shield_outlined,
    this.backgroundColor = AppColors.surfaceMuted,
    this.textColor = AppColors.navyMuted,
    this.borderColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
