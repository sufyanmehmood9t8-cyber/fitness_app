/// Primary "Next" / "Finish" button pinned to the bottom of every step.
///
/// Full-width, 48px, radius 12, blue with glow shadow.
/// Bottom margin = 16 + viewPadding.bottom.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../constants/assessment_constants.dart';

class AssessmentNextButton extends StatefulWidget {
  const AssessmentNextButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = kNextLabel,
  });

  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  @override
  State<AssessmentNextButton> createState() => _AssessmentNextButtonState();
}

class _AssessmentNextButtonState extends State<AssessmentNextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPad),
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.enabled
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x594299E1),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
