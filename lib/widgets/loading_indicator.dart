import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 30,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.8,
      ),
    );
  }
}
