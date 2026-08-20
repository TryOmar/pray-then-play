import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';

class PrayerStreakWidget extends ConsumerWidget {
  const PrayerStreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(prayerTrackingProvider);
    final completedCount = tracking.values.where((v) => v).length;
    final primaryColor = Theme.of(context).primaryColor;
    final streak = ref.watch(prayerConsistencyProvider.notifier).getConsistencyStreak();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: GlassmorphicDecoration.card(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 18, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                "TODAY'S SALAH",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/consistency'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completedCount/5 · $streak d streak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: completedCount == 5
                            ? AppColors.successGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prayer checkboxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tracking.entries.map((entry) {
              return _PrayerCheckbox(
                name: entry.key,
                isCompleted: entry.value,
                onTap: () {
                  ref
                      .read(prayerTrackingProvider.notifier)
                      .togglePrayer(entry.key);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Quick link to Heatmap & Reflection
          GestureDetector(
            onTap: () => context.go('/consistency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_graph_rounded, size: 16, color: AppColors.successGreen),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'View 5-Prayer Heatmap & Reflection',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCheckbox extends StatelessWidget {
  final String name;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PrayerCheckbox({
    required this.name,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceElevated = Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successGreen.withValues(alpha: 0.15)
                  : surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCompleted
                    ? AppColors.successGreen
                    : surfaceHighlight,
                width: isCompleted ? 1.5 : 1,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.successGreen.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 20, color: AppColors.successGreen)
                  : Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted
                  ? Theme.of(context).colorScheme.onSurface
                  : (Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
