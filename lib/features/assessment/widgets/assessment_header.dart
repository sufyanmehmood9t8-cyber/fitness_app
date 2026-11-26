/// Shared header row used by all 10 assessment steps.
///
/// Layout: [BackArrow]  "1. Personal Assessment"  [Skip]
/// Back arrow hidden on step 1; Skip hidden on step 1.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../constants/assessment_constants.dart';

class AssessmentHeader extends StatelessWidget {
  const AssessmentHeader({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onSkip,
    this.title = kAssessmentSectionTitle,
    this.showSkip = true,
    this.showBack = true,
  });

  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final String title;
  final bool showSkip;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isFirstStep = currentStep == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: <Widget>[
          // Back arrow
          if (!isFirstStep && showBack)
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 44),

          // Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Skip
          if (!isFirstStep && showSkip)
            GestureDetector(
              onTap: onSkip,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    kSkipLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
