import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/models/prayer_record.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/utils/time_utils.dart';

class PrayerStreakWidget extends ConsumerWidget {
  const PrayerStreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyRecord = ref.watch(todayPrayerRecordProvider);
    final prayerTimes = ref.watch(dailyPrayerTimesProvider);
    final completedCount = dailyRecord.completedCount;
    final primaryColor = Theme.of(context).primaryColor;
    final streak = ref.watch(prayerConsistencyProvider.notifier).getConsistencyStreak();

    final prayersList = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: GlassmorphicDecoration.card(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Stats
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    size: 15, color: AppColors.successGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S SALAH",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$completedCount / 5 Completed · ${(dailyRecord.consistencyRate).round()}% Today',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: completedCount == 5
                              ? AppColors.successGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => context.go('/consistency'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor ??
                        AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerTheme.color ??
                          AppColors.surfaceHighlight,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 13, color: AppColors.warningAmber),
                      const SizedBox(width: 3),
                      Text(
                        '$streak d streak',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warningAmber,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 13, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5 Interactive Prayer Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayersList.map((name) {
              final status =
                  dailyRecord.prayers[name] ?? PrayerStatus.notRecorded;
              final detailed = dailyRecord.detailedRecords?[name];
              final adhan = prayerTimes?.getTimeFor(name);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PrayerCard(
                    prayerName: name,
                    status: status,
                    detailedItem: detailed,
                    adhanTime: adhan,
                    onQuickTap: () {
                      ref.read(todayPrayerRecordProvider.notifier).togglePrayer(
                            name,
                            adhanTime: adhan,
                          );
                    },
                    onLongPress: () {
                      _showPrayerCorrectionDialog(
                        context: context,
                        ref: ref,
                        prayerName: name,
                        currentStatus: status,
                        detailedItem: detailed,
                        adhanTime: adhan,
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Gateway to Heatmap & Reflection
          GestureDetector(
            onTap: () => context.go('/consistency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor ??
                    AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerTheme.color ??
                      AppColors.surfaceHighlight,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 16, color: AppColors.successGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'View 5-Prayer Heatmap & Reflection',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Track consistency, on-time rates & habit balance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrayerCorrectionDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String prayerName,
    required PrayerStatus currentStatus,
    required PrayerRecordItem? detailedItem,
    required DateTime? adhanTime,
  }) {
    DateTime selectedTime = detailedItem?.completedAt ?? DateTime.now();
    PrayerStatus selectedStatus = currentStatus;
    PrayerSource selectedSource = detailedItem?.source ?? PrayerSource.manual;
    final notesController = TextEditingController(text: detailedItem?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(modalContext).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
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
                      Text(
                        'Edit $prayerName Record',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      if (adhanTime != null)
                        Text(
                          'Adhan: ${TimeUtils.formatTime(adhanTime)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Status Selector
                  const Text('PRAYER STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusOptionChip(
                        label: 'On Time',
                        color: AppColors.successGreen,
                        icon: Icons.check_circle_rounded,
                        isSelected: selectedStatus == PrayerStatus.onTime,
                        onTap: () => setModalState(() => selectedStatus = PrayerStatus.onTime),
                      ),
                      const SizedBox(width: 8),
                      _StatusOptionChip(
                        label: 'Late',
                        color: AppColors.warningAmber,
                        icon: Icons.access_time_rounded,
                        isSelected: selectedStatus == PrayerStatus.late,
                        onTap: () => setModalState(() => selectedStatus = PrayerStatus.late),
                      ),
                      const SizedBox(width: 8),
                      _StatusOptionChip(
                        label: 'Missed',
                        color: AppColors.dangerRed,
                        icon: Icons.cancel_rounded,
                        isSelected: selectedStatus == PrayerStatus.missed,
                        onTap: () => setModalState(() => selectedStatus = PrayerStatus.missed),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(todayPrayerRecordProvider.notifier).markCompleted(
                                  prayerName,
                                  status: PrayerStatus.notRecorded,
                                );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset Record'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final adhan = adhanTime ?? selectedTime;
                            final classification = PrayerRecordItem.deriveClassification(
                              adhanTime: adhan,
                              completedAt: selectedTime,
                            );

                            final item = PrayerRecordItem(
                              id: '${prayerName}_${DateTime.now().toIso8601String()}',
                              prayerName: prayerName,
                              adhanTime: adhan,
                              status: selectedStatus,
                              completedAt: selectedTime,
                              classification: classification,
                              source: selectedSource,
                              notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                              updatedAt: DateTime.now(),
                            );

                            ref.read(todayPrayerRecordProvider.notifier).saveRecordItem(item);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save Record'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String prayerName;
  final PrayerStatus status;
  final PrayerRecordItem? detailedItem;
  final DateTime? adhanTime;
  final VoidCallback onQuickTap;
  final VoidCallback onLongPress;

  const _PrayerCard({
    required this.prayerName,
    required this.status,
    required this.detailedItem,
    required this.adhanTime,
    required this.onQuickTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.isCompleted;
    final surfaceElevated = Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    final Color cardBorderColor = isCompleted
        ? (status == PrayerStatus.onTime ? AppColors.successGreen : AppColors.warningAmber)
        : (status == PrayerStatus.missed ? AppColors.dangerRed : surfaceHighlight);

    final Color cardBgColor = isCompleted
        ? (status == PrayerStatus.onTime
            ? AppColors.successGreen.withValues(alpha: 0.12)
            : AppColors.warningAmber.withValues(alpha: 0.12))
        : (status == PrayerStatus.missed
            ? AppColors.dangerRed.withValues(alpha: 0.1)
            : surfaceElevated);

    return InkWell(
      onTap: onQuickTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardBorderColor,
            width: isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: (status == PrayerStatus.onTime
                            ? AppColors.successGreen
                            : AppColors.warningAmber)
                        .withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                prayerName,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.onSurface
                      : (Theme.of(context).textTheme.bodyMedium?.color ??
                          AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                adhanTime != null ? TimeUtils.formatTime(adhanTime!) : '--:--',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Icon(
              status.icon,
              size: 16,
              color: status.color,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                status == PrayerStatus.notRecorded ? 'Tap' : status.label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: status.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOptionChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOptionChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.surfaceHighlight,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? color : AppColors.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
