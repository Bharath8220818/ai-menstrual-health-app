import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Material(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          gradient: enabled
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.4),
                    AppColors.secondaryPink.withValues(alpha: 0.4),
                  ],
                ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                }
              : null,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey<String>('loading'),
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : Row(
                        key: const ValueKey<String>('content'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
