/// Goal Selection screen – Section 2 of the onboarding flow.
///
/// Multi-select list of goal options.
/// "Next" saves goals, marks goalsDone=true and navigates to /home
/// with pushAndRemoveUntil (no back to assessment).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../assessment/constants/assessment_constants.dart';
import '../assessment/controllers/assessment_controller.dart';
import '../assessment/widgets/assessment_header.dart';
import '../assessment/widgets/assessment_next_button.dart';
import '../assessment/widgets/assessment_option_card.dart';

class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentProvider);
    final ctrl = ref.read(assessmentProvider.notifier);
    final isValid = state.goals.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/assessment');
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
              children: <Widget>[
                // Header – no progress bar on this screen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AssessmentHeader(
                    currentStep: 1, // ensures back arrow and skip are shown
                    onBack: () => context.go('/assessment'),
                    onSkip: () async {
                      await ctrl.skipGoals();
                      if (context.mounted) context.go('/home');
                    },
                    title: kGoalSectionTitle,
                  ),
                ),

                const SizedBox(height: 8),

                // Goal list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kGoalOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = kGoalOptions[index];
                      return AssessmentOptionCard(
                        label: goal,
                        selected: state.goals.contains(goal),
                        onTap: () => ctrl.toggleGoal(goal),
                      );
                    },
                  ),
                ),

                // Next button
                AssessmentNextButton(
                  enabled: isValid,
                  onPressed: () async {
                    await ctrl.finishGoals();
                    if (context.mounted) context.go('/home');
                  },
                  label: kNextLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
