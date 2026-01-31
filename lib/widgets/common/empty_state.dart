import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? message; // Alias for subtitle
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? actionText; // Alias for buttonText
  final VoidCallback? onAction; // Alias for onButtonPressed

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.message,
    this.buttonText,
    this.onButtonPressed,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final displaySubtitle = subtitle ?? message;
    final displayButtonText = buttonText ?? actionText;
    final displayOnPressed = onButtonPressed ?? onAction;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (displaySubtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                displaySubtitle,
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (displayButtonText != null && displayOnPressed != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: displayOnPressed,
                child: Text(displayButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Oops!',
      subtitle: message,
      buttonText: onRetry != null ? 'Try Again' : null,
      onButtonPressed: onRetry,
    );
  }
}
