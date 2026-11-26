import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/storage_service.dart';
import 'splash_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.initialExerciseId});

  final String? initialExerciseId;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _navigationDelay = Duration(milliseconds: 5000);

  @override
  void initState() {
    super.initState();
    Future.delayed(_navigationDelay, _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final launchExerciseId = widget.initialExerciseId;
    if (launchExerciseId != null && launchExerciseId.isNotEmpty) {
      context.go('/exercise/$launchExerciseId');
      return;
    }
    final storage = StorageService.instance;
    if (!storage.onboardingDone) {
      context.go('/onboarding');
    } else if (!storage.assessmentDone && !storage.assessmentSkipped) {
      context.go('/assessment');
    } else if (!storage.goalsDone && !storage.goalsSkipped) {
      context.go('/goal-selection');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}
