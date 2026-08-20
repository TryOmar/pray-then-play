import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/prayer_time.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/utils/time_utils.dart';

class PrayerGamingTimelineWidget extends ConsumerWidget {
  const PrayerGamingTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.watch(dailyPrayerTimesProvider);
    final userGames = ref.watch(activeSelectedGamesProvider);

    if (prayerTimes == null) return const SizedBox();

    final now = DateTime.now();
    // Timeline window: from Fajr to Isha + 2 hours
    final startOfDay = DateTime(now.year, now.month, now.day, 4, 0); // 4:00 AM
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59); // 11:59 PM
    final totalMinutesInDay = endOfDay.difference(startOfDay).inMinutes;

    final nowMinutesFromStart = now.difference(startOfDay).inMinutes;
    final nowFraction = (nowMinutesFromStart / totalMinutesInDay).clamp(0.0, 1.0);

    final primaryColor = Theme.of(context).primaryColor;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphicDecoration.card(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'PRAYER & GAMING TIMELINE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Visual Timeline Canvas
          SizedBox(
            height: 90,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Stack(
                  children: [
                    // Background bar
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 30,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceHighlight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Windows segments
                    ..._buildWindowSegments(
                      prayerTimes: prayerTimes,
                      startOfDay: startOfDay,
                      totalMinutesInDay: totalMinutesInDay,
                      width: width,
                      context: context,
                      userGames: userGames,
                    ),

                    // Prayer Markers
                    ...prayerTimes.allPrayers.map((prayer) {
                      final prayerMinutes = prayer.value.difference(startOfDay).inMinutes;
                      if (prayerMinutes < 0 || prayerMinutes > totalMinutesInDay) {
                        return const SizedBox();
                      }
                      final posX = (prayerMinutes / totalMinutesInDay) * width;

                      return Positioned(
                        left: (posX - 18).clamp(0.0, width - 36),
                        top: 4,
                        child: GestureDetector(
                          onTap: () => _showPrayerDetails(context, prayer.key, prayer.value),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                prayer.key,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 2,
                                height: 38,
                                color: primaryColor.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                TimeUtils.formatTime24(prayer.value),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // LIVE "NOW" Needle
                    Positioned(
                      left: (nowFraction * width - 1.5).clamp(0.0, width - 3.0),
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NOW',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2.5,
                              color: AppColors.dangerRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.successGreen, label: 'Good Window'),
              SizedBox(width: 16),
              _LegendItem(color: AppColors.warningAmber, label: 'Short Only'),
              SizedBox(width: 16),
              _LegendItem(color: AppColors.dangerRed, label: 'Prayer Break'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWindowSegments({
    required DailyPrayerTimes prayerTimes,
    required DateTime startOfDay,
    required int totalMinutesInDay,
    required double width,
    required BuildContext context,
    required List<dynamic> userGames,
  }) {
    final widgets = <Widget>[];
    final prayers = prayerTimes.allPrayers;

    for (int i = 0; i < prayers.length - 1; i++) {
      final current = prayers[i];
      final next = prayers[i + 1];

      final startMin = current.value.difference(startOfDay).inMinutes;
      final endMin = next.value.difference(startOfDay).inMinutes;
      if (endMin <= startMin) continue;

      // Safe window (Green)
      final safeEndMin = endMin - 30;
      if (safeEndMin > startMin) {
        final left = (startMin / totalMinutesInDay) * width;
        final segWidth = ((safeEndMin - startMin) / totalMinutesInDay) * width;

        widgets.add(
          Positioned(
            left: left,
            top: 30,
            width: segWidth,
            height: 28,
            child: GestureDetector(
              onTap: () => _showWindowDetails(
                context: context,
                title: '${current.key} to ${next.key} Gaming Slot',
                durationMinutes: safeEndMin - startMin,
                startTime: current.value,
                endTime: next.value.subtract(const Duration(minutes: 30)),
                status: GamingStatus.safe,
                userGames: userGames,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // Caution window (Amber - 30m to 10m before prayer)
      final cautionStartMin = endMin - 30;
      final cautionEndMin = endMin - 10;
      if (cautionEndMin > cautionStartMin && cautionStartMin > 0) {
        final left = (cautionStartMin / totalMinutesInDay) * width;
        final segWidth = ((cautionEndMin - cautionStartMin) / totalMinutesInDay) * width;

        widgets.add(
          Positioned(
            left: left,
            top: 30,
            width: segWidth,
            height: 28,
            child: GestureDetector(
              onTap: () => _showWindowDetails(
                context: context,
                title: 'Pre-${next.key} Short Games Window',
                durationMinutes: 20,
                startTime: next.value.subtract(const Duration(minutes: 30)),
                endTime: next.value.subtract(const Duration(minutes: 10)),
                status: GamingStatus.caution,
                userGames: userGames,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // Prayer break window (Red - 10m before to prayer time + 15m after)
      final prayerBreakStart = endMin - 10;
      final prayerBreakEnd = endMin + 15;
      final left = (prayerBreakStart / totalMinutesInDay) * width;
      final segWidth = ((prayerBreakEnd - prayerBreakStart) / totalMinutesInDay) * width;

      widgets.add(
        Positioned(
          left: left,
          top: 30,
          width: segWidth,
          height: 28,
          child: GestureDetector(
            onTap: () => _showPrayerDetails(context, next.key, next.value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.dangerRed.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  void _showPrayerDetails(BuildContext context, String name, DateTime time) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.mosque_rounded, color: AppColors.primaryCyan, size: 24),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatTime(time),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryCyan),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '$name prayer time begins at ${TimeUtils.formatTime(time)}. Complete any open matches before this time and step away from the keyboard.',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showWindowDetails({
    required BuildContext context,
    required String title,
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required GamingStatus status,
    required List<dynamic> userGames,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${TimeUtils.formatTime(startTime)} – ${TimeUtils.formatTime(endTime)} ($durationMinutes min available)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: status.color,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommended for this slot:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              status == GamingStatus.safe
                  ? 'Safe for full ranked matches, standard queues, or flexible sessions.'
                  : 'Safe only for quick arcade modes (Swiftplay, ARAM, Deathmatch) or pauseable games.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
