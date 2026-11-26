import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/workout_timer.dart';
import '../../data/models/exercise.dart';
import '../../data/seed/seed_data.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/exercise_image.dart';
import '../../widgets/flow_background.dart';
import '../../widgets/state_views.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({
    super.key,
    required this.exerciseIds,
    this.startIndex = 0,
    this.isProgramSession = false,
    this.sessionLabel,
  });

  final List<String> exerciseIds;
  final int startIndex;
  final bool isProgramSession;
  final String? sessionLabel;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late final List<Exercise> _sequence;
  late final String _sessionId;
  WorkoutTimer? _timer;
  int _index = 0;
  int _elapsedSeconds = 0;
  bool _navigated = false;
  Timer? _advanceTimer;

  Exercise get _current => _sequence[_index];

  @override
  void initState() {
    super.initState();
    final parsed = widget.exerciseIds
        .map(SeedData.byId)
        .whereType<Exercise>()
        .toList();
    final safeStart = widget.startIndex
        .clamp(0, math.max(0, parsed.length - 1))
        .toInt();
    _sequence = parsed.isEmpty ? <Exercise>[] : parsed.sublist(safeStart);
    _sessionId = 'flow_${DateTime.now().millisecondsSinceEpoch}';
    WakelockPlus.enable().catchError((Object _) {});
    if (_sequence.isNotEmpty) {
      _loadExercise(0, autoStart: true);
    }
  }

  void _loadExercise(int index, {required bool autoStart}) {
    _advanceTimer?.cancel();
    _timer?.dispose();
    final exercise = _sequence[index];
    final timer = WorkoutTimer(
      duration: Duration(seconds: exercise.durationSec),
      onComplete: _handleExerciseComplete,
    );
    timer.addListener(_onTimerChanged);
    _timer = timer;
    setState(() => _index = index);
    if (autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) timer.start();
      });
    }
  }

  void _onTimerChanged() {
    if (mounted) setState(() {});
  }

  void _handleExerciseComplete() {
    if (!mounted) return;
    setState(() => _elapsedSeconds += _current.durationSec);
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 350), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_index >= _sequence.length - 1) {
      _finish();
      return;
    }
    _loadExercise(_index + 1, autoStart: true);
  }

  void _skip() {
    _advanceTimer?.cancel();
    _elapsedSeconds += _current.durationSec;
    if (_index >= _sequence.length - 1) {
      _finish();
    } else {
      _loadExercise(_index + 1, autoStart: true);
    }
  }

  void _previous() {
    if (_index == 0) {
      _timer?.reset();
      _timer?.start();
      return;
    }
    _loadExercise(_index - 1, autoStart: false);
  }

  void _togglePlayback() {
    final timer = _timer;
    if (timer == null) return;
    if (timer.isFinished) {
      _advance();
    } else {
      timer.toggle();
    }
  }

  void _finish() {
    if (_navigated || _sequence.isEmpty) return;
    _navigated = true;
    _timer?.pause();
    final xp = _sequence.length * 40;
    final duration = _elapsedSeconds > 0
        ? _elapsedSeconds
        : _sequence.fold<int>(0, (total, item) => total + item.durationSec);
    context.pushReplacement(
      '/complete?sessionId=$_sessionId&xp=$xp&duration=$duration'
      '&exercises=${_sequence.length}&program=${widget.isProgramSession}',
    );
  }

  Future<void> _confirmClose() async {
    _timer?.pause();
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('End this session?'),
          content: const Text(
            'Your progress in this workout will not be saved.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep going'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'End session',
                style: TextStyle(color: AppColors.urgent),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (shouldEnd == true) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    } else {
      _timer?.start();
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _timer?.removeListener(_onTimerChanged);
    _timer?.dispose();
    WakelockPlus.disable().catchError((Object _) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sequence.isEmpty) {
      return FlowBackground(
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          body: FlowErrorState(
            message: 'This workout has no exercises yet.',
            onRetry: () => context.go('/category'),
          ),
        ),
      );
    }

    final timer = _timer;
    final remaining = timer?.remaining ??
        Duration(seconds: _current.durationSec);
    final progress = (_index + (timer?.progress ?? 0)) / _sequence.length;
    final next =
        _index < _sequence.length - 1 ? _sequence[_index + 1] : null;

    return Scaffold(
      backgroundColor: AppColors.primaryFaint,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.primaryFaint,
              Color(0xFFF9FCFF),
              Color(0xFFEAF4FF),
            ],
            stops: <double>[0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: 'Close workout',
                      child: GestureDetector(
                        onTap: _confirmClose,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.card,
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.sessionLabel ?? 'Workout',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Exercise ${_index + 1} of ${_sequence.length}',
                            style: AppTextStyles.bodyStrong,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            timer?.isRunning == true
                                ? LucideIcons.timer
                                : LucideIcons.pause,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            FlowDateUtils.formatClock(remaining),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const <FontFeature>[
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: AnimatedProgressBar(
                  value: progress.clamp(0.0, 1.0),
                  height: 6,
                  background: AppColors.white,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final size =
                              math.min(constraints.maxWidth * 0.7, 268.0);
                          return Container(
                            width: size + 28,
                            height: size + 28,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              child: SizedBox(
                                key: ValueKey<String>(_current.id),
                                width: size,
                                height: size,
                                child: ExerciseImage(
                                  asset: _current.imageAsset,
                                  label: _current.name,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          key: ValueKey<String>(_current.id),
                          children: <Widget>[
                            Text(
                              _current.name,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.hero,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _current.bodyParts.join(' • '),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _UpNextCard(next: next),
                    ],
                  ),
                ),
              ),
              _PlayerControls(
                isPlaying: timer?.isRunning ?? false,
                canGoPrevious: _index > 0,
                onClose: _confirmClose,
                onPrevious: _previous,
                onToggle: _togglePlayback,
                onNext: _skip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpNextCard extends StatelessWidget {
  const _UpNextCard({required this.next});

  final Exercise? next;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryFaint,
              borderRadius: BorderRadius.circular(AppRadii.button),
            ),
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: next == null
                ? const Icon(
                    LucideIcons.sparkles,
                    color: AppColors.primary,
                    size: 22,
                  )
                : ExerciseImage(
                    asset: next!.imageAsset,
                    label: next!.name,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  next == null ? 'Final stretch' : 'Up Next',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  next?.name ?? 'You are almost there',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong,
                ),
              ],
            ),
          ),
          if (next != null)
            Text(
              '${next!.durationSec}s',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.canGoPrevious,
    required this.onClose,
    required this.onPrevious,
    required this.onToggle,
    required this.onNext,
  });

  final bool isPlaying;
  final bool canGoPrevious;
  final VoidCallback onClose;
  final VoidCallback onPrevious;
  final VoidCallback onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F1FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                isPlaying ? 'Breathe with the movement' : 'Paused',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _RoundControl(
                        icon: LucideIcons.x,
                        label: 'Close',
                        onTap: onClose,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _RoundControl(
                          icon: LucideIcons.skipBack,
                          label: 'Previous exercise',
                          onTap: canGoPrevious ? onPrevious : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Semantics(
                          button: true,
                          label:
                              isPlaying ? 'Pause exercise' : 'Play exercise',
                          child: GestureDetector(
                            onTap: onToggle,
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.floating,
                              ),
                              child: Icon(
                                isPlaying
                                    ? LucideIcons.pause
                                    : LucideIcons.play,
                                color: AppColors.white,
                                size: 27,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RoundControl(
                          icon: LucideIcons.skipForward,
                          label: 'Next exercise',
                          onTap: onNext,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.white.withValues(
              alpha: 0.45,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
