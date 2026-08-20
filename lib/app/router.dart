import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/storage_service.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/queue_check/screens/queue_check_screen.dart';
import '../features/prayer_times/screens/prayer_times_screen.dart';
import '../features/game_profiles/screens/game_profiles_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/in_match/screens/in_match_screen.dart';
import '../features/session_planning/screens/session_planner_screen.dart';
import '../features/heatmap/screens/prayer_consistency_screen.dart';
import 'shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = StorageService.isOnboardingComplete;

  return GoRouter(
    initialLocation: onboardingComplete ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/queue-check',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QueueCheckScreen(),
            ),
          ),
          GoRoute(
            path: '/prayer-times',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerTimesScreen(),
            ),
          ),
          GoRoute(
            path: '/consistency',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerConsistencyScreen(),
            ),
          ),
          GoRoute(
            path: '/games',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GameProfilesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/in-match',
        builder: (context, state) => const InMatchScreen(),
      ),
      GoRoute(
        path: '/session-planner',
        builder: (context, state) => const SessionPlannerScreen(),
      ),
    ],
  );
});
