import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, coral }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final String? semanticLabel;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  Color get _background {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.coral:
        return AppColors.coral;
      case AppButtonVariant.secondary:
        return AppColors.white;
    }
  }

  Color get _foreground {
    switch (widget.variant) {
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.primary:
      case AppButtonVariant.coral:
        return AppColors.white;
    }
  }

  Border? get _border {
    if (widget.variant != AppButtonVariant.secondary) return null;
    return Border.all(color: AppColors.border);
  }

  @override
  Widget build(BuildContext context) {
    final button = AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _enabled ? 1 : 0.55,
        duration: const Duration(milliseconds: 160),
        child: SizedBox(
          height: 48,
          width: widget.expanded ? double.infinity : null,
          child: Material(
            color: _background,
            borderRadius: BorderRadius.circular(AppRadii.button),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.button),
              onTap: _enabled ? widget.onPressed : null,
              onHighlightChanged: (value) {
                if (value) setState(() => _pressed = true);
              },
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  border: _border,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: widget.expanded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  children: <Widget>[
                    if (widget.isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _foreground,
                        ),
                      )
                    else if (widget.icon != null)
                      Icon(widget.icon, size: 18, color: _foreground),
                    if (widget.icon != null || widget.isLoading)
                      const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.button.copyWith(
                          color: _foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel ?? widget.label,
      child: button,
    );
  }
}
