import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';

class FlowLoading extends StatelessWidget {
  const FlowLoading({super.key, this.label = 'Finding your flow...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class FlowEmptyState extends StatelessWidget {
  const FlowEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(icon, size: 44, color: AppColors.primary),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.coralSoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.coralBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.section,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 190,
                child: AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: LucideIcons.plus,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FlowErrorState extends StatelessWidget {
  const FlowErrorState({
    super.key,
    this.message =
        'Something interrupted the flow. Please try again in a moment.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.coralSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                color: AppColors.coral,
                size: 38,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Could not load this yet',
              textAlign: TextAlign.center,
              style: AppTextStyles.section,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 160,
                child: AppButton(
                  label: 'Try again',
                  onPressed: onRetry,
                  variant: AppButtonVariant.secondary,
                  icon: LucideIcons.refreshCw,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
