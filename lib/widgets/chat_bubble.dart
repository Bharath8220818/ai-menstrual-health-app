import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/widgets/typing_indicator.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.isUser,
    required this.index,
    this.message,
    this.isTyping = false,
  });

  final String? message;
  final bool isUser;
  final bool isTyping;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.botBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radius),
          topRight: const Radius.circular(AppSpacing.radius),
          bottomLeft: Radius.circular(isUser ? AppSpacing.radius : 6),
          bottomRight: Radius.circular(isUser ? 6 : AppSpacing.radius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isTyping
          ? const TypingIndicator()
          : Text(
              message ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textDark,
                height: 1.35,
              ),
            ),
    );

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 220 + (index * 12)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * (isUser ? 24 : -24), 0),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }
}
