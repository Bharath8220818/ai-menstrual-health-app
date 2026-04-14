import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

class CurvedGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CurvedGradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 104 : 120);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: AppSpacing.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
