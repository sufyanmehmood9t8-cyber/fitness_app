import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.trailing,
    this.topPadding = AppSpacing.lg,
  });

  final String title;
  final Widget? trailing;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: AppTextStyles.section),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
