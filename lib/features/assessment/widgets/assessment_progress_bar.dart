/// Dashed segment progress bar used in the assessment header.
///
/// 10 equally-wide rounded segments with 6px gap.
/// Filled segments = [filledCount], rest are light grey.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AssessmentProgressBar extends StatelessWidget {
  const AssessmentProgressBar({
    super.key,
    required this.total,
    required this.filledCount,
  });

  final int total;
  final int filledCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final totalGap = gap * (total - 1);
        final segmentWidth = (constraints.maxWidth - totalGap) / total;

        return Row(
          children: List<Widget>.generate(total, (i) {
            final filled = i < filledCount;
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: segmentWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: filled
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
