import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

class CycleProgressBar extends StatelessWidget {
  const CycleProgressBar({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: clamped,
            backgroundColor: AppColors.accent.withValues(alpha: 0.5),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
