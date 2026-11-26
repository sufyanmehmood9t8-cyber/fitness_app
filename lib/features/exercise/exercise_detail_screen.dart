import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise.dart';
import '../../data/seed/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/exercise_image.dart';
import '../../widgets/flow_background.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tag_chip.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    this.sessionQuery,
  });

  final String exerciseId;
  final String? sessionQuery;

  Exercise? get _exercise => SeedData.byId(exerciseId);

  List<Exercise> _session(Exercise exercise) {
    final requested = (sessionQuery ?? '')
        .split(',')
        .where((id) => id.isNotEmpty)
        .map(SeedData.byId)
        .whereType<Exercise>()
        .toList();
    if (requested.isNotEmpty) return requested;
    final category = SeedData.exercisesForCategory(exercise.category);
    return category.isEmpty ? <Exercise>[exercise] : category;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    if (exercise == null) {
      return FlowBackground(
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                const AppTopBar(title: 'Exercise'),
                Expanded(
                  child: FlowErrorState(
                    message: 'This exercise could not be found.',
                    onRetry: () => context.go('/category'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final session = _session(exercise);
    final startIndex = session.indexWhere((item) => item.id == exercise.id);
    final isTodayFlow = _sameIds(
      session.map((item) => item.id).toList(),
      SeedData.todayFlowIds,
    );
    final pageTitle = isTodayFlow ? 'Today Flow' : exercise.category;
    final totalSeconds =
        session.fold<int>(0, (total, item) => total + item.durationSec);

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: FlowBackground(
        child: Column(
          children: <Widget>[
            AppTopBar(title: pageTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _HeroCard(
                      exercise: exercise,
                      totalSeconds: totalSeconds,
                      sessionCount: session.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(exercise.name, style: AppTextStyles.hero),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: exercise.bodyParts
                          .map((part) => TagChip(label: part))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('How to do it', style: AppTextStyles.section),
                    const SizedBox(height: AppSpacing.sm),
                    ...List<Widget>.generate(
                      exercise.steps.length,
                      (index) => _StepRow(
                        number: index + 1,
                        text: exercise.steps[index],
                        isLast: index == exercise.steps.length - 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _DetailActions(
        onStart: () {
          final ids = session.map((item) => item.id).join(',');
          context.push(
            '/player?ids=$ids&start=${startIndex < 0 ? 0 : startIndex}'
            '&label=${Uri.encodeComponent(pageTitle)}',
          );
        },
        onCancel: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
    );
  }

  bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.exercise,
    required this.totalSeconds,
    required this.sessionCount,
  });

  final Exercise exercise;
  final int totalSeconds;
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    final minutes = (totalSeconds / 60).ceil();
    return Container(
      height: 264,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.white,
            AppColors.primaryFaint,
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -38,
            top: -38,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft.withValues(alpha: 0.7),
              ),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -36,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coralSoft.withValues(alpha: 0.7),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: ExerciseImage(
                asset: exercise.imageAsset,
                label: exercise.name,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadii.chip),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    LucideIcons.clock3,
                    size: 14,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$minutes min',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: Text(
                '$sessionCount exercises',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.isLast,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(text, style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.onStart, required this.onCancel});

  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Start Exercise',
                  icon: LucideIcons.play,
                  onPressed: onStart,
                  semanticLabel: 'Start exercise',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  onPressed: onCancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
