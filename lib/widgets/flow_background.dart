import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FlowBackground extends StatelessWidget {
  const FlowBackground({
    super.key,
    required this.child,
    this.applyTopSafeArea = true,
    this.gradient = AppColors.screenGradient,
  });

  final Widget child;
  final bool applyTopSafeArea;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
          stops: const <double>[0, 0.42, 1],
        ),
      ),
      child: applyTopSafeArea ? SafeArea(bottom: false, child: child) : child,
    );
  }
}
