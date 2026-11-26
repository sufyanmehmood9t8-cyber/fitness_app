import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/providers/app_providers.dart';
import '../../data/seed/seed_data.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/category_card.dart';
import '../../widgets/flow_background.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tag_chip.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, this.bodyPart});

  final String? bodyPart;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _visibleCategories() {
    final all = ref.watch(categoriesProvider);
    var categories = widget.bodyPart == null
        ? all
        : SeedData.categoriesForBodyPart(widget.bodyPart!);
    final normalized = _query.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      categories = categories.where((category) {
        if (category.toLowerCase().contains(normalized)) return true;
        return SeedData.exercisesForCategory(category).any((exercise) {
          return exercise.name.toLowerCase().contains(normalized) ||
              exercise.bodyParts.any(
                (part) => part.toLowerCase().contains(normalized),
              );
        });
      }).toList();
    }
    return categories;
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _visibleCategories();
    final bodyPart = widget.bodyPart;

    return FlowBackground(
      child: Column(
        children: <Widget>[
          AppTopBar(
            title: 'Categories',
            actions: <Widget>[
              Semantics(
                button: true,
                label: _searching ? 'Close search' : 'Search categories',
                child: GestureDetector(
                  onTap: _toggleSearch,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _searching ? LucideIcons.x : LucideIcons.search,
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _searching
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search categories or poses',
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(
                                  LucideIcons.x,
                                  size: 17,
                                  color: AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (bodyPart != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Filtered by',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  TagChip(
                    label: bodyPart,
                    selected: true,
                    icon: LucideIcons.x,
                    onTap: () => context.go('/category'),
                  ),
                  const Spacer(),
                  Text(
                    '${categories.length} flows',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Find your flow',
                    style: AppTextStyles.bodyStrong,
                  ),
                  const Spacer(),
                  Text(
                    '${categories.length} categories',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                final mediaQuery = MediaQuery.of(context);
                final screenWidth = mediaQuery.size.width;
                final navHeight = screenWidth < 360 ? 56.0 : 64.0;
                final bottomPadding =
                    navHeight + 12.0 + mediaQuery.viewPadding.bottom + 16.0;
                if (categories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: FlowEmptyState(
                      icon: LucideIcons.search,
                      title: 'No flows found',
                      message: _query.isEmpty
                          ? 'There are no categories for this body part yet.'
                          : 'Try another pose, category, or body part.',
                      actionLabel: _query.isEmpty ? null : 'Clear search',
                      onAction: _query.isEmpty
                          ? null
                          : () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                    ),
                  );
                }
                return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      bottomPadding,
                    ),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final exercises =
                          SeedData.exercisesForCategory(category);
                      if (exercises.isEmpty) return const SizedBox.shrink();
                      final first = exercises.first;
                      final session =
                          exercises.map((item) => item.id).join(',');
                      return CategoryCard(
                        title: category,
                        imageAsset:
                            SeedData.imageForCategory(category),
                        durationLabel: FlowDateUtils.durationBadge(
                          exercises.map((item) => item.durationSec),
                        ),
                        exercises: exercises,
                        onTap: () => context.push(
                          '/exercise/${first.id}?session=$session',
                        ),
                      );
                    },
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
