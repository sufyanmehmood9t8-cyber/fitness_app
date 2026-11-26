import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_progress.dart';
import '../../data/providers/app_providers.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/flow_background.dart';

class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  const WorkoutCompleteScreen({
    super.key,
    required this.sessionId,
    required this.xp,
    required this.durationSeconds,
    required this.exerciseCount,
    this.isProgramSession = false,
  });

  final String sessionId;
  final int xp;
  final int durationSeconds;
  final int exerciseCount;
  final bool isProgramSession;

  @override
  ConsumerState<WorkoutCompleteScreen> createState() =>
      _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState
    extends ConsumerState<WorkoutCompleteScreen> {
  late final ConfettiController _confetti;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  Future<void> _save() async {
    if (_saved || !mounted) return;
    _saved = true;
    await ref.read(progressProvider.notifier).completeWorkout(
          sessionId: widget.sessionId,
          xp: widget.xp,
          duration: Duration(seconds: widget.durationSeconds),
          exerciseCount: widget.exerciseCount,
        );
    if (!mounted) return;
    _confetti.play();
  }

  String get _durationLabel {
    if (widget.durationSeconds < 60) {
      return '${widget.durationSeconds} sec';
    }
    final minutes = widget.durationSeconds ~/ 60;
    final seconds = widget.durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} min';
  }

  void _showProgress(UserProgress progress) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Your progress', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Every session adds a little more ease.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ProgressRow(
                  icon: LucideIcons.zap,
                  label: 'Total XP',
                  value: '${progress.stats.xp} XP',
                ),
                _ProgressRow(
                  icon: LucideIcons.flame,
                  label: 'Current streak',
                  value: '${progress.stats.streak} days',
                ),
                _ProgressRow(
                  icon: LucideIcons.clock3,
                  label: 'Minutes moved',
                  value: '${progress.stats.totalMinutes} min',
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFaint,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        progress.program.name,
                        style: AppTextStyles.bodyStrong,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedProgressBar(
                        value: progress.program.progress,
                        height: 7,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Day ${progress.program.currentDay} of '
                        '${progress.program.days}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final program = progress.program;
    final percent = (program.progress * 100).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Stack(
        children: <Widget>[
          FlowBackground(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            AppColors.primary,
                            Color(0xFF75BCEB),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.floating,
                      ),
                      child: const Icon(
                        LucideIcons.check,
                        size: 48,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Great job!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'You showed up for yourself today.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coralSoft,
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                        border: Border.all(color: AppColors.coralBorder),
                      ),
                      child: Text(
                        '${widget.exerciseCount} moves completed',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Today's stats",
                        style: AppTextStyles.section,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _CompletionStat(
                            icon: LucideIcons.zap,
                            label: 'XP Earned',
                            value: '+${widget.xp}',
                            unit: 'XP',
                            iconBackground: AppColors.blueCircle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _CompletionStat(
                            icon: LucideIcons.flame,
                            label: 'Streak',
                            value: '${progress.stats.streak}',
                            unit: 'days',
                            iconBackground: AppColors.coralSoft,
                            iconColor: AppColors.coral,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _CompletionStat(
                            icon: LucideIcons.clock3,
                            label: 'Time',
                            value: _durationLabel,
                            iconBackground: AppColors.blueCircle,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isProgramSession) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primarySoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.trendingUp,
                                    size: 19,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        program.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyStrong,
                                      ),
                                      Text(
                                        'Day ${program.currentDay} of '
                                        '${program.days}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AnimatedProgressBar(
                              value: program.progress,
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'View Progress',
                      icon: LucideIcons.barChart3,
                      onPressed: () => _showProgress(progress),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Back to Home',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        widget.exerciseCount.clamp(1, 8),
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Saved to your progress',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.03,
                numberOfParticles: 34,
                maxBlastForce: 22,
                minBlastForce: 8,
                gravity: 0.18,
                colors: const <Color>[
                  AppColors.primary,
                  AppColors.coral,
                  Color(0xFFFFCF5C),
                  Color(0xFF8ED1B2),
                  AppColors.white,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  const _CompletionStat({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.iconBackground,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.section.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (unit != null) ...<Widget>[
            const SizedBox(height: 1),
            Text(unit!, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primaryFaint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
