import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/time_utils.dart';

class NextPrayerHeroWidget extends StatelessWidget {
  final String prayerName;
  final DateTime? prayerTime;
  final Duration countdown;
  final int minutesRemaining;
  final int bufferMinutes;

  const NextPrayerHeroWidget({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.countdown,
    required this.minutesRemaining,
    this.bufferMinutes = 10,
  });

  @override
  Widget build(BuildContext context) {
    final primaryAccent = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final highlightColor = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    final statusColor = minutesRemaining <= 0
        ? AppColors.dangerRed
        : minutesRemaining <= bufferMinutes
            ? AppColors.dangerRed
            : minutesRemaining <= (bufferMinutes + 15)
                ? AppColors.warningAmber
                : primaryAccent;

    final progress = minutesRemaining <= 0
        ? 1.0
        : (1.0 - (minutesRemaining / 120)).clamp(0.05, 1.0);

    String guidanceText;
    if (minutesRemaining <= 0) {
      guidanceText = '$prayerName time has arrived. Complete your game and pray.';
    } else if (minutesRemaining <= bufferMinutes) {
      guidanceText = '$prayerName is very close. Do not queue for long matches.';
    } else if (minutesRemaining <= (bufferMinutes + 15)) {
      guidanceText = 'You have time for a short match or flexible session.';
    } else {
      guidanceText = 'You have a comfortable gaming window with safety buffer.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: GlassmorphicDecoration.neonCard(
        context: context,
        glowColor: statusColor,
        glowIntensity: minutesRemaining <= bufferMinutes ? 0.25 : 0.12,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer name & time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName.isEmpty ? 'NEXT PRAYER' : prayerName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        minutesRemaining <= 0
                            ? 'NOW'
                            : 'in ${TimeUtils.formatCountdown(countdown)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (prayerTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    TimeUtils.formatTime(prayerTime!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: highlightColor,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 14),

          // Guidance Message
          Text(
            guidanceText,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 18),

          // "What can I play?" Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/queue-check'),
              icon: const Icon(Icons.sports_esports_rounded, size: 18),
              label: const Text('What can I play?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
