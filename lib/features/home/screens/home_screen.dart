import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../widgets/next_prayer_hero_widget.dart';
import '../widgets/prayer_gaming_timeline_widget.dart';
import '../widgets/recommended_games_widget.dart';
import '../widgets/prayer_streak_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _ticker;
  Duration _countdown = Duration.zero;
  String _nextPrayerName = '';
  DateTime? _nextPrayerTime;
  int _minutesUntilPrayer = 999;

  @override
  void initState() {
    super.initState();
    _updateState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateState();
    });
  }

  void _updateState() {
    final lat = StorageService.latitude;
    final lng = StorageService.longitude;
    if (lat == null || lng == null) return;

    final nextPrayer = PrayerService.getNextPrayer(
      latitude: lat,
      longitude: lng,
      method: StorageService.calculationMethod,
      asrMethod: StorageService.asrMethod,
    );

    if (nextPrayer != null && mounted) {
      final remaining = nextPrayer.value.difference(DateTime.now());
      setState(() {
        _nextPrayerName = nextPrayer.key;
        _nextPrayerTime = nextPrayer.value;
        _countdown = remaining.isNegative ? Duration.zero : remaining;
        _minutesUntilPrayer = _countdown.inMinutes;
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = StorageService.cityName;
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);
    final activeTheme = Theme.of(context);

    final onSurface = activeTheme.colorScheme.onSurface;
    final textSecondary = activeTheme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Scaffold(
      backgroundColor: activeTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          LinearGradient(colors: [
                            activeTheme.primaryColor,
                            onSurface,
                          ]).createShader(bounds),
                      child: Text(
                        'GamerSalah',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/settings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: activeTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: activeTheme.dividerTheme.color ?? AppColors.surfaceHighlight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 14, color: activeTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              city,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Next Prayer Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: NextPrayerHeroWidget(
                  prayerName: _nextPrayerName,
                  prayerTime: _nextPrayerTime,
                  countdown: _countdown,
                  minutesRemaining: _minutesUntilPrayer,
                  bufferMinutes: bufferMinutes,
                ),
              ),
            ),

            // Quick Actions: "Can I Queue?" & "I'm In A Match"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.sports_esports_rounded,
                        label: 'Can I Queue?',
                        color: Theme.of(context).primaryColor,
                        onTap: () => context.go('/queue-check'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.play_circle_outline_rounded,
                        label: "I'm In A Match",
                        color: AppColors.warningAmber,
                        onTap: () => context.push('/in-match'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Interactive Prayer & Gaming Timeline
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: PrayerGamingTimelineWidget(),
              ),
            ),

            // Personalized Recommendations
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: RecommendedGamesWidget(
                  minutesUntilPrayer: _minutesUntilPrayer,
                ),
              ),
            ),

            // Today's 5 Prayers Tracker
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: PrayerStreakWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: GlassmorphicDecoration.neonCard(
          context: context,
          glowColor: color,
          glowIntensity: 0.1,
          borderRadius: 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
