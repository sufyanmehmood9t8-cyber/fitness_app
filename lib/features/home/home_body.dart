import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise.dart';
import '../../data/models/program.dart';
import '../../data/providers/app_providers.dart';
import '../../data/seed/seed_data.dart';
import '../../data/services/storage_service.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/flow_background.dart';
import '../../widgets/pressable_scale.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final program = progress.program;
    final reminderCount = ref.watch(remindersProvider).length;
    final currentProgramExercise = SeedData.byId(
      program.currentExerciseId ?? SeedData.programIds.first,
    );
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final navHeight = screenWidth < 360 ? 56.0 : 64.0;
    final bottomPadding =
        navHeight + mediaQuery.viewPadding.bottom + 16.0;

    return FlowBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: _HomeHeader(reminderCount: reminderCount),
            ),
            const SizedBox(height: AppSpacing.xs),
            _BodyPartCarousel(screenWidth: screenWidth),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _AddReminderCard(
                    onTap: () => context.push('/reminders/new'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TodayFlowCard(
                    onTap: () {
                      final session = SeedData.todayFlowIds.join(',');
                      context.push(
                        '/exercise/split-training?session=$session',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Continue Program',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProgramCard(
                    program: program,
                    currentExercise: currentProgramExercise,
                    onTap: () => _resumeProgram(context, program),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resumeProgram(BuildContext context, Program program) {
    final start = program.currentExerciseIndex
        .clamp(0, program.exerciseIds.length - 1);
    final ids = program.exerciseIds.sublist(start);
    if (ids.isEmpty) return;
    context.push(
      '/player?ids=${ids.join(',')}&start=0&program=true',
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.reminderCount});

  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    String displayName = 'Alex crew';
    try {
      final name = StorageService.instance.userName.trim();
      if (name.isNotEmpty) {
        displayName = name;
      }
    } catch (_) {}
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xxs),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Hi, ',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: displayName,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: reminderCount > 0
              ? 'Saved reminders, $reminderCount saved'
              : 'Saved reminders',
          child: GestureDetector(
            onTap: () => context.push('/reminders'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Icon(
                    LucideIcons.bell,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  if (reminderCount > 0)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyPartCarousel extends StatefulWidget {
  const _BodyPartCarousel({required this.screenWidth});

  final double screenWidth;

  @override
  State<_BodyPartCarousel> createState() => _BodyPartCarouselState();
}

class _BodyPartCarouselState extends State<_BodyPartCarousel> {
  static const double _viewportFraction = 0.20;

  static const List<_BubbleSpec> _items = <_BubbleSpec>[
    _BubbleSpec(label: 'Arms', asset: 'assets/images/arms.webp'),
    _BubbleSpec(label: 'Neck', asset: 'assets/images/Neck.webp'),
    _BubbleSpec(label: 'Shoulder', asset: 'assets/images/shoulder.webp'),
    _BubbleSpec(
      label: 'Hamstring',
      asset: 'assets/images/Hamstring.webp',
    ),
    _BubbleSpec(label: 'Chest', asset: 'assets/images/chest.webp'),
    _BubbleSpec(label: 'Core', asset: 'assets/images/core.webp'),
    _BubbleSpec(label: 'Hip', asset: 'assets/images/hip.webp'),
    _BubbleSpec(label: 'Glutes', asset: 'assets/images/glutes.webp'),
    _BubbleSpec(label: 'Quads', asset: 'assets/images/quads.webp'),
    _BubbleSpec(label: 'Calves', asset: 'assets/images/calves.webp'),
    _BubbleSpec(label: 'Ankles', asset: 'assets/images/ankles.webp'),
    _BubbleSpec(
      label: 'Lower Back',
      asset: 'assets/images/lower-back.webp',
    ),
    _BubbleSpec(
      label: 'Upper Back',
      asset: 'assets/images/upper-back.webp',
    ),
    _BubbleSpec(label: 'Yoga', asset: 'assets/images/yoga.webp'),
    _BubbleSpec(label: 'Split', asset: 'assets/images/split.webp'),
    _BubbleSpec(label: 'Morning', asset: 'assets/images/morning.webp'),
  ];

  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: _viewportFraction,
      initialPage: 2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.screenWidth;
    final centerSize = width * 0.21;
    final middleSize = width * 0.155;
    final edgeSize = width * 0.11;
    final middleDrop = width * 0.08;
    final edgeDrop = width * 0.19;
    final pageWidth = width * _viewportFraction;
    const labelHeight = 26.0;
    const bottomGap = 8.0;
    final sectionHeight =
        centerSize + edgeDrop + labelHeight + bottomGap;

    return SizedBox(
      height: sectionHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: PageView.builder(
          controller: _controller,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final page = _controller.hasClients &&
                        _controller.page != null
                    ? _controller.page!
                    : _controller.initialPage.toDouble();
                final double delta =
                    (index - page).abs().clamp(0.0, 2.0).toDouble();
                final double size;
                final double dy;
                if (delta <= 1) {
                  size = centerSize +
                      (middleSize - centerSize) * delta;
                  dy = middleDrop * delta;
                } else {
                  final double t = delta - 1;
                  size = middleSize +
                      (edgeSize - middleSize) * t;
                  dy = middleDrop + (edgeDrop - middleDrop) * t;
                }
                final itemWidth = size + 24;
                final left = (pageWidth - itemWidth) / 2;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: left,
                      top: 0,
                      child: Transform.translate(
                        offset: Offset(0, dy),
                        child: _Bubble(
                          spec: _items[index],
                          size: size,
                          labelFontSize: delta >= 1.5 ? 8 : 9,
                          onTap: () => context.push(
                            '/category?bodyPart='
                            '${Uri.encodeComponent(_items[index].label)}',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.spec,
    required this.size,
    required this.labelFontSize,
    required this.onTap,
  });

  final _BubbleSpec spec;
  final double size;
  final double labelFontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${spec.label} stretches',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: size + 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(size * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.75),
                    width: 1.5,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    spec.asset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(
                        color: Color(0xFFE5E7EB),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: BoxConstraints(maxWidth: size + 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  spec.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleSpec {
  const _BubbleSpec({required this.label, required this.asset});

  final String label;
  final String asset;
}

class _AddReminderCard extends StatelessWidget {
  const _AddReminderCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Add reminder',
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF4B8A5)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE7DF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.list,
                color: Color(0xFFF58A6B),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Add Reminder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Set your reminder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE7DF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: Color(0xFFF58A6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayFlowCard extends StatelessWidget {
  const _TodayFlowCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Open today flow, day 2',
      child: Container(
        height: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBD9F5)),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 14),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEBFA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.dumbbell,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Today Flow',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Day 2',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 96,
                height: 84,
                child: Image.asset(
                  SeedData.todayFlowImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(color: Color(0xFFE5E7EB));
                  },
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.currentExercise,
    required this.onTap,
  });

  final Program program;
  final Exercise? currentExercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel:
          'Continue ${program.name}, day ${program.currentDay}, '
          '${currentExercise?.name ?? 'next exercise'}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        program.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Day ${program.currentDay} • '
                        '${currentExercise?.name ?? 'Next stretch'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.maximize2,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedProgressBar(
              value: program.progress,
              height: 6,
              background: const Color(0xFFE5E7EB),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
