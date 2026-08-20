import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/models/prayer_time.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/risk_calculator.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:async';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  DailyPrayerTimes? _prayerTimes;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _loadPrayerTimes() {
    final lat = StorageService.latitude;
    final lng = StorageService.longitude;
    if (lat == null || lng == null) return;

    _prayerTimes = PrayerService.calculatePrayerTimes(
      latitude: lat,
      longitude: lng,
      date: DateTime.now(),
      method: StorageService.calculationMethod,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(prayerTrackingProvider);
    final city = StorageService.cityName;

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _prayerTimes == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prayer Times',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$city  \u2022  ${TimeUtils.formatDate(DateTime.now())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prayer cards
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        _prayerTimes!.allTimings.map((entry) {
                          final name = entry.key;
                          final time = entry.value;
                          final now = DateTime.now();
                          final isPassed = now.isAfter(time);
                          final isNext = !isPassed &&
                              _prayerTimes!.getNextPrayer(now)?.key == name;
                          final isCompleted = tracking[name] ?? false;

                          // Get end time
                          final endTime =
                              _prayerTimes!.getEndTimeForPrayer(name);
                          final isCurrent = isPassed &&
                              endTime != null &&
                              now.isBefore(endTime);

                          // Minutes until this prayer
                          final minutesUntil = isPassed
                              ? 0
                              : time.difference(now).inMinutes;

                          final status = isCurrent
                              ? GamingStatus.prayerTime
                              : isNext
                                  ? RiskCalculator.calculateGamingStatus(
                                      minutesUntil)
                                  : GamingStatus.safe;

                          final statusColor = isCurrent
                              ? AppColors.dangerRed
                              : isNext
                                  ? status.color
                                  : AppColors.textSecondary;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (isCurrent || isNext)
                                    ? statusColor.withValues(alpha: 0.08)
                                    : surfaceColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (isCurrent || isNext)
                                      ? statusColor.withValues(alpha: 0.35)
                                      : surfaceHighlight,
                                  width: (isCurrent || isNext) ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Prayer status
                                  GestureDetector(
                                    onTap: name != 'Sunrise'
                                        ? () {
                                            ref
                                                .read(todayPrayerRecordProvider
                                                    .notifier)
                                                .togglePrayer(name);
                                          }
                                        : null,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.successGreen
                                                .withValues(alpha: 0.15)
                                            : statusColor
                                                .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppColors.successGreen
                                              : statusColor
                                                  .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(Icons.check_rounded,
                                              size: 18,
                                              color: AppColors.successGreen)
                                          : Icon(
                                              isCurrent
                                                  ? Icons.mosque_rounded
                                                  : Icons
                                                      .circle_outlined,
                                              size: 16,
                                              color: statusColor,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Name + time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isPassed && !isCurrent
                                                ? (Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted)
                                                : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        if (endTime != null)
                                          Text(
                                            '${TimeUtils.formatTime(time)} - ${TimeUtils.formatTime(endTime)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Time
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        TimeUtils.formatTime(time),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: (isCurrent || isNext)
                                              ? statusColor
                                              : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary),
                                        ),
                                      ),
                                      if (isNext)
                                        Text(
                                          'in ${minutesUntil}m',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (isCurrent)
                                        Text(
                                          'NOW',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
