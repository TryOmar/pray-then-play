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
      final safeMins = (remainingMinutes - bufferMinutes).clamp(0, 9999);
      statusSubtitle = 'Up to ~$safeMins min available. Ideal for Swiftplay, ARAM, or casual.';
      statusColor = AppColors.warningAmber;
    } else {
      status = GamingStatus.safe;
      final safeMins = (remainingMinutes - bufferMinutes).clamp(0, 9999);
      statusBadge = 'SAFE TO PLAY';
      statusSubtitle = 'Up to ~$safeMins min safe session with a ${bufferMinutes}m buffer.';
      statusColor = primaryAccent;
    }

    final safeMinutesAvailable = (remainingMinutes - bufferMinutes).clamp(0, 9999);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: GlassmorphicDecoration.neonCard(
        context: context,
        glowColor: statusColor,
        glowIntensity: remainingMinutes <= bufferMinutes ? 0.22 : 0.12,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Next Prayer Badge + Live Sync Beacon + Time Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prayerName.isEmpty ? 'NEXT PRAYER' : prayerName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      TimeUtils.formatTime(prayerTime!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Isolated Live Countdown + Micro Status Chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: _LiveCountdownWidget(prayerTime: prayerTime!),
              ),
              if (remainingMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '~$safeMinutesAvailable min safe',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Safety Evaluation Pill (Modern Glassmorphic Capsule)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    status == GamingStatus.safe
                        ? Icons.sports_esports_rounded
                        : status == GamingStatus.caution
                            ? Icons.timelapse_rounded
                            : Icons.mosque_rounded,
                    size: 17,
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
                          fontSize: 11.5,
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
                          color: Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.textMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                try {
                  context.go('/queue-check');
                } catch (_) {}
              },
              icon: const Icon(Icons.shield_outlined, size: 16),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Evaluate Match Queue Safety',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: statusColor.computeLuminance() > 0.55
                    ? Colors.black
                    : Colors.white,
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

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 2,
      children: [
        Text(
          isArrived ? 'NOW' : TimeUtils.formatCountdown(remaining),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: onSurface,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          isArrived ? 'Adhan reached' : 'remaining',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodySmall?.color ??
                AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
