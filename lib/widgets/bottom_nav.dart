import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeIndex,
    required this.onSelect,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;

  static const List<_NavDestination> _destinations = <_NavDestination>[
    _NavDestination('Home', LucideIcons.home),
    _NavDestination('Category', LucideIcons.layoutGrid),
    _NavDestination('Setting', LucideIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final systemBottomInset = mediaQuery.viewPadding.bottom;
    final textScaler = mediaQuery.textScaler.clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.1,
    );

    final navHeight = screenWidth < 360 ? 56.0 : 64.0;
    final horizontalMargin = 16.0;
    final bottomMargin = 12.0 + systemBottomInset;

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: textScaler),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalMargin,
          0,
          horizontalMargin,
          bottomMargin,
        ),
        child: Container(
          height: navHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            children: List<Widget>.generate(_destinations.length, (index) {
              final destination = _destinations[index];
              final selected = index == activeIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: destination.label,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(index),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: screenWidth < 360 ? 42.0 : 46.0,
                        padding: EdgeInsets.symmetric(
                          horizontal: selected ? AppSpacing.md : AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              destination.icon,
                              size: screenWidth < 360 ? 18 : 20,
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textMuted,
                            ),
                            if (selected) ...<Widget>[
                              const SizedBox(width: 6),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    destination.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
