import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/storage_service.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/queue_check/screens/queue_check_screen.dart';
import '../features/game_profiles/screens/game_profiles_screen.dart';
import '../features/settings/screens/settings_screen.dart';
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
          // Hub 1: Can I Queue? (Primary Dashboard)
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QueueCheckScreen(),
            ),
          ),
          GoRoute(
            path: '/queue-check',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QueueCheckScreen(),
            ),
          ),
          // Hub 2: Prayer Consistency & Today's Prayers
          GoRoute(
            path: '/consistency',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerConsistencyScreen(),
            ),
          ),
          // Hub 3: Settings & Games Configuration
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          // Sub-route: Game Library Management
          GoRoute(
            path: '/games',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GameProfilesScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
