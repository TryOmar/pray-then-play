import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';

class GamingStatusWidget extends StatelessWidget {
  final GamingStatus status;
  final int minutesUntilPrayer;
  final String nextPrayerName;

  const GamingStatusWidget({
    super.key,
    required this.status,
    required this.minutesUntilPrayer,
    required this.nextPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(18),
      decoration: GlassmorphicDecoration.statusCard(
        context: context,
        statusColor: config.color,
      ),
      child: Row(
        children: [
          // Status indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: config.color.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(config.icon, color: config.color, size: 24),
          ),
          const SizedBox(width: 14),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${minutesUntilPrayer}m',
              style: TextStyle(
                color: config.color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig() {
    switch (status) {
      case GamingStatus.safe:
        return _StatusConfig(
          icon: Icons.check_circle_rounded,
          color: AppColors.successGreen,
          title: 'Safe to play',
          subtitle: 'You have enough time before $nextPrayerName.',
        );
      case GamingStatus.caution:
        return _StatusConfig(
          icon: Icons.warning_rounded,
          color: AppColors.warningAmber,
          title: 'Be careful',
          subtitle: '$nextPrayerName is approaching. Choose shorter games.',
        );
      case GamingStatus.dontQueue:
        return _StatusConfig(
          icon: Icons.block_rounded,
          color: AppColors.dangerRed,
          title: "Don't queue",
          subtitle: '$nextPrayerName is very close. Pray first.',
        );
      case GamingStatus.prayerTime:
        return _StatusConfig(
          icon: Icons.mosque_rounded,
          color: AppColors.dangerRed,
          title: 'Prayer time',
          subtitle: '$nextPrayerName time has arrived. Time to pray.',
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _StatusConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}
