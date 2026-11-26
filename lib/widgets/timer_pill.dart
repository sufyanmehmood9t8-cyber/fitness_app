import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class TimerPill extends StatelessWidget {
  const TimerPill({
    super.key,
    required this.time,
    this.icon = LucideIcons.clock,
  });

  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Timer $time',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              time,
              style: AppTextStyles.section.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
