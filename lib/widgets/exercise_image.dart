import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class ExerciseImage extends StatelessWidget {
  const ExerciseImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.contain,
    this.label,
  });

  final String asset;
  final BoxFit fit;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: label ?? 'Exercise illustration',
      child: Image.asset(
        asset,
        fit: fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.primaryFaint,
                  AppColors.primarySoft,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.dumbbell,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
