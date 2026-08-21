import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/utils/time_utils.dart';

class PrayerCountdownWidget extends StatelessWidget {
  final String prayerName;
  final DateTime? prayerTime;
  final Duration countdown;
  final int minutesRemaining;

  const PrayerCountdownWidget({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.countdown,
    required this.minutesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    // Progress for the ring (based on 2-hour window)
    final progress = minutesRemaining <= 0
        ? 1.0
        : (1.0 - (minutesRemaining / 120)).clamp(0.0, 1.0);

    final primaryColor = Theme.of(context).primaryColor;
    final ringColor = minutesRemaining <= 5
        ? AppColors.dangerRed
        : minutesRemaining <= 15
            ? AppColors.warningAmber
            : primaryColor;

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textMuted =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final trackColor =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: GlassmorphicDecoration.card(
        context: context,
        customBorder: ringColor.withValues(alpha: 0.25),
        glow: true,
      ),
      child: Column(
        children: [
          // Prayer name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mosque_rounded, size: 18, color: ringColor),
              const SizedBox(width: 8),
              Text(
                prayerName.isEmpty ? 'Loading...' : prayerName.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ringColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Countdown ring
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    color: trackColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        color: ringColor,
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                // Inner glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ringColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Countdown text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TimeUtils.formatCountdown(countdown),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Prayer time
          if (prayerTime != null)
            Text(
              'Begins at ${TimeUtils.formatTime(prayerTime!)}',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
