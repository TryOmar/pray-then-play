import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_logo_widget.dart';
import '../widgets/next_prayer_hero_widget.dart';
import '../widgets/prayer_gaming_timeline_widget.dart';
import '../widgets/prayer_streak_widget.dart';
import '../widgets/recommended_games_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = StorageService.cityName;
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final activeTheme = Theme.of(context);

    final onSurface = activeTheme.colorScheme.onSurface;
    final textSecondary = activeTheme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    final nextPrayerName = nextPrayer?.key ?? '';
    final nextPrayerTime = nextPrayer?.value;
    final minutesUntilPrayer = nextPrayerTime != null
        ? nextPrayerTime.difference(DateTime.now()).inMinutes
        : 999;

    return Scaffold(
      backgroundColor: activeTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 900;

            if (isWideScreen) {
              return _buildWideDesktopLayout(
                context: context,
                city: city,
                onSurface: onSurface,
                textSecondary: textSecondary,
                activeTheme: activeTheme,
                nextPrayerName: nextPrayerName,
                nextPrayerTime: nextPrayerTime,
                minutesUntilPrayer: minutesUntilPrayer,
                bufferMinutes: bufferMinutes,
              );
            }

            return _buildMobileLayout(
              context: context,
              city: city,
              onSurface: onSurface,
              textSecondary: textSecondary,
              activeTheme: activeTheme,
              nextPrayerName: nextPrayerName,
              nextPrayerTime: nextPrayerTime,
              minutesUntilPrayer: minutesUntilPrayer,
              bufferMinutes: bufferMinutes,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout({
    required BuildContext context,
    required String city,
    required Color onSurface,
    required Color textSecondary,
    required ThemeData activeTheme,
    required String nextPrayerName,
    required DateTime? nextPrayerTime,
    required int minutesUntilPrayer,
    required int bufferMinutes,
  }) {
    return CustomScrollView(
      slivers: [
        // Top Header Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildHeaderBar(context, city, onSurface, textSecondary, activeTheme),
          ),
        ),

        // Hero Next Prayer Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: NextPrayerHeroWidget(
              prayerName: nextPrayerName,
              prayerTime: nextPrayerTime,
              bufferMinutes: bufferMinutes,
            ),
          ),
        ),

        // Quick Actions Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _buildQuickActionsRow(context),
          ),
        ),

        // Precision 24H Timeline
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: PrayerGamingTimelineWidget(),
          ),
        ),

        // Today's 5 Prayers Tracker
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: PrayerStreakWidget(),
          ),
        ),

        // Personalized Recommendations
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: RecommendedGamesWidget(
              minutesUntilPrayer: minutesUntilPrayer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideDesktopLayout({
    required BuildContext context,
    required String city,
    required Color onSurface,
    required Color textSecondary,
    required ThemeData activeTheme,
    required String nextPrayerName,
    required DateTime? nextPrayerTime,
    required int minutesUntilPrayer,
    required int bufferMinutes,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBar(context, city, onSurface, textSecondary, activeTheme),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Hero, Quick Actions, Recommendations)
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    NextPrayerHeroWidget(
                      prayerName: nextPrayerName,
                      prayerTime: nextPrayerTime,
                      bufferMinutes: bufferMinutes,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsRow(context),
                    const SizedBox(height: 20),
                    RecommendedGamesWidget(minutesUntilPrayer: minutesUntilPrayer),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column (24H Timeline, Salah Tracker)
              Expanded(
                flex: 6,
                child: Column(
                  children: const [
                    PrayerGamingTimelineWidget(),
                    SizedBox(height: 20),
                    PrayerStreakWidget(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(
    BuildContext context,
    String city,
    Color onSurface,
    Color textSecondary,
    ThemeData activeTheme,
  ) {
    return Row(
      children: [
        const AppLogoWidget(
          size: 32,
          variant: AppLogoVariant.iconOnly,
          showGlow: true,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pray Then Play',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: onSurface,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'STAY ON TIME • PLAY WITH PEACE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: activeTheme.primaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go('/settings'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: activeTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activeTheme.dividerTheme.color ?? AppColors.surfaceHighlight,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: activeTheme.primaryColor),
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
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.shield_rounded,
            label: 'Can I Queue?',
            color: Theme.of(context).primaryColor,
            onTap: () => context.go('/queue-check'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.play_circle_outline_rounded,
            label: "In a Match",
            color: AppColors.warningAmber,
            onTap: () => context.push('/in-match'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.event_note_rounded,
            label: "Planner",
            color: AppColors.successGreen,
            onTap: () => context.push('/session-planner'),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: GlassmorphicDecoration.neonCard(
          context: context,
          glowColor: color,
          glowIntensity: 0.08,
          borderRadius: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
