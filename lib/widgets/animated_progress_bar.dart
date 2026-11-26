import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.background = AppColors.chip,
    this.color = AppColors.primary,
    this.duration = const Duration(milliseconds: 700),
  });

  final double value;
  final double height;
  final Color background;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: value.clamp(0.0, 1.0),
              ),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * animatedValue,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
