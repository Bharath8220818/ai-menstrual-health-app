import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.values,
  });

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(height: 170);
    }

    final normalized = values.take(6).toList();
    final maxValue = normalized.reduce(math.max).toDouble();

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(normalized.length, (index) {
          final value = normalized[index];
          final ratio = value / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ratio),
                    duration: Duration(milliseconds: 480 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, barValue, _) {
                      return Container(
                        height: 24 + (barValue * 110),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.primary, AppColors.secondaryPink],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'C${index + 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
