import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QualityBadge extends StatelessWidget {
  final String label;
  final bool large;

  const QualityBadge({
    super.key,
    required this.label,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    IconData icon;

    final normalized = label.trim().toLowerCase();
    if (normalized.contains('grade a')) {
      bg = AppColors.healthyGreenBg;
      text = AppColors.healthyGreen;
      border = AppColors.healthyGreenBorder;
      icon = Icons.verified;
    } else if (normalized.contains('urs')) {
      bg = AppColors.warningAmberBg;
      text = AppColors.warningAmber;
      border = AppColors.warningAmberBorder;
      icon = Icons.published_with_changes;
    } else if (normalized.contains('reject')) {
      bg = AppColors.rejectRedBg;
      text = AppColors.rejectRed;
      border = AppColors.rejectRedBorder;
      icon = Icons.cancel;
    } else {
      bg = AppColors.warningAmberBg;
      text = AppColors.warningAmber;
      border = AppColors.warningAmberBorder;
      icon = Icons.pending_actions;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 18 : 14, color: text),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: large ? 14 : 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
