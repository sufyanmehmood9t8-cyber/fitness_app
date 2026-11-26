/// Personal Assessment flow – 10 steps driven by [kAssessmentSteps].
///
/// One reusable screen renders all steps; adding a new step only
/// requires a new entry in assessment_constants.dart / assessment_step_def.dart.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'constants/assessment_constants.dart';
import 'controllers/assessment_controller.dart';
import 'models/assessment_state.dart';
import 'models/assessment_step_def.dart';
import 'widgets/assessment_header.dart';
import 'widgets/assessment_next_button.dart';
import 'widgets/assessment_option_card.dart';
import 'widgets/assessment_progress_bar.dart';
import 'widgets/step_bodies/gender_step_body.dart';
import 'widgets/step_bodies/height_step_body.dart';
import 'widgets/step_bodies/name_step_body.dart';
import 'widgets/step_bodies/sitting_hours_step_body.dart';
import 'widgets/step_bodies/weight_step_body.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  // Tracks slide direction for custom transition.
  bool _goingForward = true;

  // ── Navigation ─────────────────────────────────────────────

  Future<void> _next() async {
    final ctrl = ref.read(assessmentProvider.notifier);
    final step = ref.read(assessmentProvider).currentStep;

    if (step == kTotalAssessmentSteps - 1) {
      // Last step → finish assessment, go to Goal Selection.
      await ctrl.finishAssessment();
      if (mounted) context.go('/goal-selection');
    } else {
      setState(() => _goingForward = true);
      ctrl.nextStep();
    }
  }

  void _back() {
    final step = ref.read(assessmentProvider).currentStep;
    if (step == 0) {
      _showExitDialog();
      return;
    }
    setState(() => _goingForward = false);
    ref.read(assessmentProvider.notifier).prevStep();
  }

  Future<void> _skip() async {
    final ctrl = ref.read(assessmentProvider.notifier);
    await ctrl.skipAssessment();
    if (mounted) context.go('/goal-selection');
  }

  void _showExitDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Assessment?'),
        content:
            const Text('Your progress will be saved. You can resume later.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              context.go('/home');
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Color(0xFFE5484D)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);
    final ctrl = ref.read(assessmentProvider.notifier);
    final step = state.currentStep;
    final stepDef = kAssessmentSteps[step];
    final isValid = ctrl.isCurrentStepValid();
    final isLastStep = step == kTotalAssessmentSteps - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.screenGradient,
              stops: <double>[0, 0.42, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AssessmentHeader(
                    currentStep: step,
                    onBack: _back,
                    onSkip: _skip,
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AssessmentProgressBar(
                    total: kTotalAssessmentSteps,
                    filledCount: step + 1,
                  ),
                ),

                // Question title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    stepDef.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Step content (animated slide)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final offset = _goingForward
                          ? const Offset(0.06, 0)
                          : const Offset(-0.06, 0);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: offset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _StepContent(
                      key: ValueKey<int>(step),
                      step: step,
                      stepDef: stepDef,
                    ),
                  ),
                ),

                // Next / Finish button
                AssessmentNextButton(
                  enabled: isValid,
                  onPressed: _next,
                  label: isLastStep ? kFinishLabel : kNextLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Step content dispatcher
// ──────────────────────────────────────────────────────────────

class _StepContent extends ConsumerWidget {
  const _StepContent({
    super.key,
    required this.step,
    required this.stepDef,
  });

  final int step;
  final AssessmentStepDef stepDef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessState = ref.watch(assessmentProvider);
    final ctrl = ref.read(assessmentProvider.notifier);

    Widget body;
    switch (stepDef.type) {
      case AssessmentStepType.text:
        body = NameStepBody(
          initialValue: assessState.name,
          onChanged: ctrl.setName,
        );

      case AssessmentStepType.gender:
        body = GenderStepBody(
          gender: assessState.gender,
          onSelect: (g) => ctrl.setGender(g),
        );

      case AssessmentStepType.height:
        body = HeightStepBody(
          heightCm: assessState.heightCm,
          selectedUnit: assessState.heightUnit,
          heightFeet: assessState.heightFeet,
          heightInches: assessState.heightInches,
          onHeightCmChanged: ctrl.setHeightCm,
          onUnitChanged: ctrl.setHeightUnit,
          onFeetInchesChanged: ctrl.setHeightFeetInches,
        );

      case AssessmentStepType.weight:
        body = WeightStepBody(
          weightKg: assessState.weightKg,
          selectedUnit: assessState.weightUnit,
          onWeightKgChanged: ctrl.setWeightKg,
          onUnitChanged: ctrl.setWeightUnit,
        );

      case AssessmentStepType.singleSelect:
        body = _SingleSelectList(
          options: stepDef.options,
          selected: _getSingleSelectValue(assessState, step),
          onSelect: (val) => _setSingleSelectValue(ctrl, step, val),
        );

      case AssessmentStepType.multiSelect:
        body = _MultiSelectList(
          options: stepDef.options,
          selected: assessState.painAreas,
          onToggle: ctrl.togglePainArea,
        );

      case AssessmentStepType.number:
        body = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SittingHoursStepBody(
            initialValue: assessState.sittingHours,
            onChanged: ctrl.setSittingHours,
          ),
        );
    }

    // Wrap scrollable content types
    if (stepDef.type == AssessmentStepType.singleSelect ||
        stepDef.type == AssessmentStepType.multiSelect) {
      return body;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: body,
    );
  }

  String _getSingleSelectValue(AssessmentState assessState, int step) {
    switch (step) {
      case 4:
        return assessState.fitnessLevel;
      case 5:
        return assessState.occupation;
      case 7:
        return assessState.activityLevel;
      case 9:
        return assessState.flexibilityLevel;
      default:
        return '';
    }
  }

  void _setSingleSelectValue(AssessmentController ctrl, int step, String val) {
    switch (step) {
      case 4:
        ctrl.setFitnessLevel(val);
      case 5:
        ctrl.setOccupation(val);
      case 7:
        ctrl.setActivityLevel(val);
      case 9:
        ctrl.setFlexibilityLevel(val);
    }
  }
}

// ──────────────────────────────────────────────────────────────
//  Single-select list
// ──────────────────────────────────────────────────────────────

class _SingleSelectList extends StatelessWidget {
  const _SingleSelectList({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final opt = options[index];
        return AssessmentOptionCard(
          label: opt,
          selected: opt == selected,
          onTap: () => onSelect(opt),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Multi-select list
// ──────────────────────────────────────────────────────────────

class _MultiSelectList extends StatelessWidget {
  const _MultiSelectList({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final opt = options[index];
        return AssessmentOptionCard(
          label: opt,
          selected: selected.contains(opt),
          onTap: () => onToggle(opt),
        );
      },
    );
  }
}
