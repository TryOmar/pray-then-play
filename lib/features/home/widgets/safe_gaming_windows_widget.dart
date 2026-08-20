import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/utils/time_utils.dart';

class SafeGamingWindowsWidget extends ConsumerWidget {
  const SafeGamingWindowsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windows = ref.watch(gamingWindowsProvider);

    if (windows.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TODAY'S GAMING WINDOWS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        ...windows.map((window) {
          final color = _getStatusColor(window.status);
          final isCurrent = window.isCurrentWindow;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? color.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? color.withValues(alpha: 0.4)
                      : AppColors.surfaceHighlight,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Time range
                  SizedBox(
                    width: 110,
                    child: Text(
                      '${TimeUtils.formatTime24(window.start)}  -  ${TimeUtils.formatTime24(window.end)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),

                  // Status dot
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                  ),

                  // Label
                  Expanded(
                    child: Text(
                      window.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isCurrent ? color : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Duration
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'NOW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getStatusColor(GamingStatus status) {
    switch (status) {
      case GamingStatus.safe:
        return AppColors.successGreen;
      case GamingStatus.caution:
        return AppColors.warningAmber;
      case GamingStatus.dontQueue:
      case GamingStatus.prayerTime:
        return AppColors.dangerRed;
    }
  }
}
