import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/learning/presentation/screens/learning_screen.dart';
import 'features/life_designer/presentation/screens/life_designer_screen.dart';
import 'features/medicine/presentation/screens/medicine_screen.dart';
import 'features/nutrition/presentation/screens/nutrition_screen.dart';
import 'features/results/presentation/screens/results_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/sleep/presentation/screens/sleep_screen.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';
import 'features/timeline/presentation/screens/timeline_screen.dart';
import 'features/workout/presentation/screens/workout_screen.dart';

/// Navigation Summary (docs/03_System_Architecture.md §14): 5 persistent
/// bottom tabs, GoRouter, deep linking supported via StatefulShellRoute
/// (preserves each tab's navigation stack independently).
///
/// Workout, Learning, Nutrition, Medicine, and Sleep are reachable as
/// sub-routes under Tasks for MVP (their own bottom-nav placement isn't
/// specified by any RFC — RFC-002 only specifies the Tasks tab itself),
/// rather than invented as new unspecified tabs. Settings is reachable
/// as a sub-route under Life Designer, matching docs/rfc/RFC-014_
/// Settings.md §6 ("reachable from Life Designer, remains its own
/// screen").
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
            routes: [
              GoRoute(path: 'workout', builder: (context, state) => const WorkoutScreen()),
              GoRoute(path: 'learning', builder: (context, state) => const LearningScreen()),
              GoRoute(path: 'nutrition', builder: (context, state) => const NutritionScreen()),
              GoRoute(path: 'medicine', builder: (context, state) => const MedicineScreen()),
              GoRoute(path: 'sleep', builder: (context, state) => const SleepScreen()),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/timeline', builder: (context, state) => const TimelineScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/results', builder: (context, state) => const ResultsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/life-designer',
            builder: (context, state) => const LifeDesignerScreen(),
            routes: [
              GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
            ],
          ),
        ]),
      ],
    ),
  ],
);
