import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/utils/time_utils.dart';

class NextPrayerHeroWidget extends ConsumerWidget {
  final String prayerName;
  final DateTime? prayerTime;
  final int bufferMinutes;

  const NextPrayerHeroWidget({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.bufferMinutes = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryAccent = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    if (prayerTime == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: GlassmorphicDecoration.card(context: context),
        child: const Center(
          child: Text('Calculating next prayer time...'),
        ),
      );
    }

    final now = DateTime.now();
    final remainingMinutes = prayerTime!.difference(now).inMinutes;

    // Safety classification
    final GamingStatus status;
    final String statusBadge;
    final String statusSubtitle;
    final Color statusColor;

    if (remainingMinutes <= 0) {
      status = GamingStatus.prayerTime;
      statusBadge = 'PRAYER TIME';
      statusSubtitle = '$prayerName has arrived. Step away from the screen and pray.';
      statusColor = AppColors.dangerRed;
    } else if (remainingMinutes <= bufferMinutes) {
      status = GamingStatus.dontQueue;
      statusBadge = 'PRAYER APPROACHING';
      statusSubtitle = '$prayerName is within your ${bufferMinutes}m safety buffer.';
      statusColor = AppColors.dangerRed;
    } else if (remainingMinutes <= (bufferMinutes + 20)) {
      status = GamingStatus.caution;
      statusBadge = 'SHORT MATCH ONLY';
      final safeMins = remainingMinutes - bufferMinutes;
      statusSubtitle = 'Up to ~$safeMins min available. Ideal for Swiftplay, ARAM, or casual.';
      statusColor = AppColors.warningAmber;
    } else {
      status = GamingStatus.safe;
      final safeMins = remainingMinutes - bufferMinutes;
      statusBadge = 'SAFE TO PLAY';
      statusSubtitle = 'Up to ~$safeMins min safe session with a ${bufferMinutes}m buffer.';
      statusColor = primaryAccent;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: GlassmorphicDecoration.neonCard(
        context: context,
        glowColor: statusColor,
        glowIntensity: remainingMinutes <= bufferMinutes ? 0.22 : 0.1,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Prayer Label & Time Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                ),
                child: Text(
                  prayerName.isEmpty ? 'NEXT PRAYER' : prayerName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      TimeUtils.formatTime(prayerTime!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Isolated Live Countdown
          _LiveCountdownWidget(prayerTime: prayerTime!),

          const SizedBox(height: 16),

          // Safety Evaluation Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == GamingStatus.safe
                        ? Icons.sports_esports_rounded
                        : status == GamingStatus.caution
                            ? Icons.timelapse_rounded
                            : Icons.mosque_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusBadge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/queue-check'),
              icon: const Icon(Icons.shield_outlined, size: 18),
              label: const Text('Evaluate Match Queue Safety'),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: statusColor == AppColors.warningAmber ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCountdownWidget extends ConsumerWidget {
  final DateTime prayerTime;

  const _LiveCountdownWidget({required this.prayerTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only this small subtree rebuilds every second
    final nowAsync = ref.watch(liveSecondTickerProvider);
    final now = nowAsync.value ?? DateTime.now();

    final remaining = prayerTime.difference(now);
    final isArrived = remaining.isNegative;
    final totalRemainingMinutes = remaining.inMinutes;

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          isArrived ? 'NOW' : TimeUtils.formatCountdown(remaining),
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: onSurface,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isArrived ? 'Adhan reached' : 'remaining',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
