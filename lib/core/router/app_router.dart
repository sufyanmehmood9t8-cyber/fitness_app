import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/assessment_screen.dart';
import '../../features/assessment/goal_selection_screen.dart';
import '../../features/category/category_screen.dart';
import '../../features/complete/workout_complete_screen.dart';
import '../../features/exercise/exercise_detail_screen.dart';
import '../../features/home/home_body.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/player/workout_player_screen.dart';
import '../../features/reminders/reminder_editor_screen.dart';
import '../../features/reminders/saved_reminders_screen.dart';
import '../../features/settings/help_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../widgets/state_views.dart';

const String _splashPath = '/splash';

GoRouter createAppRouter({String? initialExerciseId}) {
  return GoRouter(
    initialLocation: _splashPath,
    redirect: (context, state) {
      if (state.matchedLocation == _splashPath) return null;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: _splashPath,
        name: 'splash',
        builder: (context, state) => SplashScreen(
          initialExerciseId: initialExerciseId,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/goal-selection',
        name: 'goal-selection',
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/category',
            name: 'category',
            builder: (context, state) => CategoryScreen(
              bodyPart: state.uri.queryParameters['bodyPart'],
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/exercise/:id',
        name: 'exercise',
        builder: (context, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['id'] ?? '',
          sessionQuery: state.uri.queryParameters['session'],
        ),
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final ids = (query['ids'] ?? '')
              .split(',')
              .where((id) => id.isNotEmpty)
              .toList();
          return WorkoutPlayerScreen(
            exerciseIds: ids,
            startIndex: int.tryParse(query['start'] ?? '') ?? 0,
            isProgramSession: query['program'] == 'true',
            sessionLabel: query['label'],
          );
        },
      ),
      GoRoute(
        path: '/complete',
        name: 'complete',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return WorkoutCompleteScreen(
            sessionId: query['sessionId'] ?? '',
            xp: int.tryParse(query['xp'] ?? '') ?? 0,
            durationSeconds:
                int.tryParse(query['duration'] ?? '') ?? 0,
            exerciseCount:
                int.tryParse(query['exercises'] ?? '') ?? 0,
            isProgramSession: query['program'] == 'true',
          );
        },
      ),
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const SavedRemindersScreen(),
      ),
      GoRoute(
        path: '/reminders/new',
        name: 'new-reminder',
        builder: (context, state) => ReminderEditorScreen(
          editId: state.uri.queryParameters['edit'],
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: SafeArea(
          child: FlowErrorState(
            message: 'The page you were looking for could not be found.',
            onRetry: () => context.go('/home'),
          ),
        ),
      );
    },
  );
}
