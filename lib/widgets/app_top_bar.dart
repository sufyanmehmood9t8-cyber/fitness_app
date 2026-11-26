import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const <Widget>[],
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBack;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          if (showBack) ...<Widget>[
            Semantics(
              button: true,
              label: 'Go back',
              child: SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: AppColors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _handleBack(context),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      size: 21,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title,
            ),
          ),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            ...actions,
          ],
        ],
      ),
    );
  }
}
