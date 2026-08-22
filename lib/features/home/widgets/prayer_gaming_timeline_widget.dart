import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/models/prayer_record.dart';
import '../../../core/models/prayer_time.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/game_icon_widget.dart';

class PrayerGamingTimelineWidget extends ConsumerWidget {
  const PrayerGamingTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.watch(dailyPrayerTimesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final userGames = ref.watch(activeSelectedGamesProvider);
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);
    final is24Hour = ref.watch(timeFormatIs24HourProvider);

    if (prayerTimes == null) return const SizedBox();

    final primaryColor = Theme.of(context).primaryColor;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    final axisLabels = is24Hour
        ? const ['00:00', '06:00', '12:00', '18:00', '23:59']
        : context.isRtl
            ? const ['12 ص', '6 ص', '12 م', '6 م', '12 ص']
            : const ['12 AM', '6 AM', '12 PM', '6 PM', '12 AM'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphicDecoration.card(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.timeline_rounded, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('timeline_header').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('timeline_sub'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color ??
                            AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _LiveBadge(primaryColor: primaryColor),
            ],
          ),
          const SizedBox(height: 18),

          // Visual Timeline Canvas (Clean HUD)
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 38,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  const totalMinutes = 1440.0; // 24 hours in minutes

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Base track
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 6,
                        height: 26,
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceHighlight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: surfaceHighlight.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Mathematical Window Segments (Green Safe, Amber Buffer, Red Prayer)
                      ..._buildMathematicalSegments(
                        prayerTimes: prayerTimes,
                        bufferMinutes: bufferMinutes,
                        width: width,
                        totalMinutes: totalMinutes,
                        context: context,
                        ref: ref,
                        userGames: userGames,
                        is24Hour: is24Hour,
                      ),

                      // Prayer Marker Tick Beacons (Exact, Non-overlapping)
                      ..._buildPrayerMarkerTicks(
                        prayerTimes: prayerTimes,
                        width: width,
                        totalMinutes: totalMinutes,
                        context: context,
                        ref: ref,
                        primaryColor: primaryColor,
                        is24Hour: is24Hour,
                      ),

                      // Pulsing LIVE NOW Needle
                      _LiveNeedle(width: width, totalMinutes: totalMinutes),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 24H Axis Grid Markers (Dynamic 12 AM/PM or 24H format)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: axisLabels.map((lbl) {
                return Text(
                  lbl,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Perfectly Aligned Symmetrical 5-Prayer Cards Strip
          Directionality(
            textDirection: TextDirection.ltr,
            child: _buildPrayerScheduleStrip(
              context: context,
              ref: ref,
              prayerTimes: prayerTimes,
              nextPrayer: nextPrayer,
              primaryColor: primaryColor,
              surfaceHighlight: surfaceHighlight,
              is24Hour: is24Hour,
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendItem(
                  color: AppColors.successGreen, label: context.tr('safe_to_play_short')),
              _LegendItem(
                  color: AppColors.warningAmber, label: context.tr('safety_buffer')),
              _LegendItem(color: AppColors.dangerRed, label: context.tr('prayer_time_badge')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerScheduleStrip({
    required BuildContext context,
    required WidgetRef ref,
    required DailyPrayerTimes prayerTimes,
    required MapEntry<String, DateTime>? nextPrayer,
    required Color primaryColor,
    required Color surfaceHighlight,
    required bool is24Hour,
  }) {
    final prayers = prayerTimes.allPrayers;
    final now = DateTime.now();
    final record = ref.watch(todayPrayerRecordProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        final items = prayers.map((prayer) {
          final isNext = nextPrayer?.key == prayer.key;
          final isPast =
              now.isAfter(prayer.value.add(const Duration(minutes: 15)));
          final loggedStatus =
              record.prayers[prayer.key] ?? PrayerStatus.notRecorded;
          final isRecorded = loggedStatus == PrayerStatus.onTime ||
              loggedStatus == PrayerStatus.late ||
              loggedStatus == PrayerStatus.missed;

          final cardColor = isRecorded
              ? loggedStatus.color.withValues(alpha: 0.12)
              : (isNext
                  ? primaryColor.withValues(alpha: 0.1)
                  : surfaceHighlight.withValues(alpha: 0.18));

          final borderColor = isRecorded
              ? loggedStatus.color.withValues(alpha: 0.55)
              : (isNext
                  ? primaryColor.withValues(alpha: 0.6)
                  : surfaceHighlight.withValues(alpha: 0.35));

          final itemContent = Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: (isNext || isRecorded) ? 1 : 0.6,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRecorded) ...[
                        Icon(loggedStatus.icon,
                            size: 10.5, color: loggedStatus.color),
                        const SizedBox(width: 3),
                      ] else if (isNext) ...[
                        Container(
                          width: 4.5,
                          height: 4.5,
                          margin: const EdgeInsets.only(right: 3.5),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.7),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        context.tr('prayer_${prayer.key.toLowerCase()}'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              (isNext || isRecorded) ? FontWeight.w800 : FontWeight.w600,
                          color: isRecorded
                              ? loggedStatus.color
                              : (isNext
                                  ? primaryColor
                                  : (isPast
                                      ? AppColors.textMuted
                                      : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color ??
                                          AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isRecorded
                        ? loggedStatus.getLocalizedLabel(context)
                        : TimeUtils.formatTime(prayer.value, is24Hour: is24Hour),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          (isNext || isRecorded) ? FontWeight.w700 : FontWeight.w500,
                      color: isRecorded
                          ? loggedStatus.color
                          : (isNext
                              ? primaryColor
                              : (isPast
                                  ? AppColors.textMuted.withValues(alpha: 0.7)
                                  : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color ??
                                      AppColors.textMuted)),
                    ),
                  ),
                ),
              ],
            ),
          );

          return GestureDetector(
            onTap: () => _showPrayerInfoModal(
                context, ref, prayer.key, prayer.value,
                is24Hour: is24Hour),
            child: itemContent,
          );
        }).toList();

        if (isCompact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 72,
                    child: w,
                  ),
                );
              }).toList(),
            ),
          );
        }

        return Row(
          children: items.map((w) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: w,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildPrayerMarkerTicks({
    required DailyPrayerTimes prayerTimes,
    required double width,
    required double totalMinutes,
    required BuildContext context,
    required WidgetRef ref,
    required Color primaryColor,
    required bool is24Hour,
  }) {
    final prayers = prayerTimes.allPrayers;
    final widgets = <Widget>[];
    final record = ref.watch(todayPrayerRecordProvider);

    for (final prayer in prayers) {
      final minuteOfDay = prayer.value.hour * 60.0 +
          prayer.value.minute +
          prayer.value.second / 60.0;
      final exactX = (minuteOfDay / totalMinutes) * width;
      final loggedStatus =
          record.prayers[prayer.key] ?? PrayerStatus.notRecorded;
      final isRecorded = loggedStatus == PrayerStatus.onTime ||
          loggedStatus == PrayerStatus.late ||
          loggedStatus == PrayerStatus.missed;
      final tickColor = isRecorded ? loggedStatus.color : primaryColor;

      widgets.add(
        Positioned(
          left: (exactX - 1.0).clamp(0.0, width - 2.0),
          top: 2,
          bottom: 2,
          child: GestureDetector(
            onTap: () => _showPrayerInfoModal(
                context, ref, prayer.key, prayer.value,
                is24Hour: is24Hour),
            child: Container(
              width: isRecorded ? 2.5 : 2.0,
              decoration: BoxDecoration(
                color: tickColor,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: tickColor.withValues(alpha: 0.7),
                    blurRadius: isRecorded ? 4 : 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildMathematicalSegments({
    required DailyPrayerTimes prayerTimes,
    required int bufferMinutes,
    required double width,
    required double totalMinutes,
    required BuildContext context,
    required WidgetRef ref,
    required List<GameProfile> userGames,
    required bool is24Hour,
  }) {
    final widgets = <Widget>[];
    final prayers = prayerTimes.allPrayers;

    for (int i = 0; i < prayers.length; i++) {
      final current = prayers[i];
      final next = (i + 1 < prayers.length) ? prayers[i + 1] : null;

      final currentMin = current.value.hour * 60.0 + current.value.minute;

      // 1. Prayer Window (Adhan to Adhan + 15 min)
      final prayerEndMin = currentMin + 15;
      final pLeft = (currentMin / totalMinutes) * width;
      final pWidth = (15 / totalMinutes) * width;

      widgets.add(
        Positioned(
          left: pLeft,
          top: 6,
          width: pWidth.clamp(3.0, width),
          height: 26,
          child: GestureDetector(
            onTap: () => _showPrayerInfoModal(
                context, ref, current.key, current.value,
                is24Hour: is24Hour),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.8), width: 0.8),
              ),
            ),
          ),
        ),
      );

      if (next != null) {
        final nextMin = next.value.hour * 60.0 + next.value.minute;
        if (nextMin <= prayerEndMin) continue;

        // 2. Safe Gaming Window (Adhan + 15m to Next Adhan - bufferMinutes)
        final safeEndMin = nextMin - bufferMinutes;
        if (safeEndMin > prayerEndMin) {
          final sLeft = (prayerEndMin / totalMinutes) * width;
          final sWidth = ((safeEndMin - prayerEndMin) / totalMinutes) * width;
          final availableMinutes = (safeEndMin - prayerEndMin).round();

          widgets.add(
            Positioned(
              left: sLeft,
              top: 6,
              width: sWidth.clamp(2.0, width),
              height: 26,
              child: GestureDetector(
                onTap: () => _showWindowInspectionModal(
                  context: context,
                  title: '${current.key} ➔ ${next.key} Gaming Window',
                  durationMinutes: availableMinutes,
                  startTime: current.value.add(const Duration(minutes: 15)),
                  endTime: next.value.subtract(Duration(minutes: bufferMinutes)),
                  status: GamingStatus.safe,
                  userGames: userGames,
                  is24Hour: is24Hour,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.6), width: 0.8),
                  ),
                ),
              ),
            ),
          );
        }

        // 3. Pre-Prayer Caution Buffer (Next Adhan - bufferMinutes to Next Adhan)
        final cautionStartMin = nextMin - bufferMinutes;
        if (cautionStartMin > prayerEndMin) {
          final cLeft = (cautionStartMin / totalMinutes) * width;
          final cWidth = (bufferMinutes / totalMinutes) * width;

          widgets.add(
            Positioned(
              left: cLeft,
              top: 6,
              width: cWidth.clamp(2.0, width),
              height: 26,
              child: GestureDetector(
                onTap: () => _showWindowInspectionModal(
                  context: context,
                  title: 'Pre-${next.key} Caution Buffer',
                  durationMinutes: bufferMinutes,
                  startTime: next.value.subtract(Duration(minutes: bufferMinutes)),
                  endTime: next.value,
                  status: GamingStatus.caution,
                  userGames: userGames,
                  is24Hour: is24Hour,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.7), width: 0.8),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  void _showPrayerInfoModal(
    BuildContext context,
    WidgetRef ref,
    String name,
    DateTime time, {
    bool is24Hour = false,
  }) {
    final activeTheme = Theme.of(context);
    final primaryColor = activeTheme.primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: activeTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final liveRecord =
              ref.read(prayerConsistencyProvider.notifier).getRecord(DateTime.now());
          final activeStatus = liveRecord.prayers[name] ?? PrayerStatus.notRecorded;
          final isFuture = time.isAfter(DateTime.now());

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.mosque_rounded, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('prayer_${name.toLowerCase()}'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            context.tr('adhan_time_label').replaceAll(
                                '{time}',
                                TimeUtils.formatTime(time,
                                    is24Hour: is24Hour)),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: activeStatus.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: activeStatus.color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(activeStatus.icon, size: 14, color: activeStatus.color),
                          const SizedBox(width: 4),
                          Text(
                            activeStatus.getLocalizedLabel(context),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: activeStatus.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isFuture) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryCyan.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: AppColors.primaryCyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('future_prayer_notice'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const Text(
                  'MARK PRAYER STATUS TODAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatusLogOption(
                      ctx: ctx,
                      ref: ref,
                      name: name,
                      targetStatus: PrayerStatus.onTime,
                      label: PrayerStatus.onTime.getLocalizedLabel(context),
                      icon: Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      isSelected: activeStatus == PrayerStatus.onTime,
                      setModalState: setModalState,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusLogOption(
                      ctx: ctx,
                      ref: ref,
                      name: name,
                      targetStatus: PrayerStatus.late,
                      label: PrayerStatus.late.getLocalizedLabel(context),
                      icon: Icons.access_time_rounded,
                      color: AppColors.warningAmber,
                      isSelected: activeStatus == PrayerStatus.late,
                      setModalState: setModalState,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusLogOption(
                      ctx: ctx,
                      ref: ref,
                      name: name,
                      targetStatus: PrayerStatus.missed,
                      label: PrayerStatus.missed.getLocalizedLabel(context),
                      icon: Icons.cancel_rounded,
                      color: AppColors.dangerRed,
                      isSelected: activeStatus == PrayerStatus.missed,
                      setModalState: setModalState,
                    ),
                  ],
                ),
                if (activeStatus != PrayerStatus.notRecorded) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(prayerConsistencyProvider.notifier).updatePrayerStatus(
                              DateTime.now(),
                              name,
                              PrayerStatus.notRecorded,
                            );
                        ref.read(todayPrayerRecordProvider.notifier).markCompleted(
                              name,
                              status: PrayerStatus.notRecorded,
                            );
                        setModalState(() {});
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('$name ${context.tr('clear_prayer_status').toLowerCase()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textMuted),
                      label: Text(
                        context.tr('clear_prayer_status'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusLogOption({
    required BuildContext ctx,
    required WidgetRef ref,
    required String name,
    required PrayerStatus targetStatus,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required StateSetter setModalState,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final newStatus = isSelected ? PrayerStatus.notRecorded : targetStatus;
          ref.read(prayerConsistencyProvider.notifier).updatePrayerStatus(
                DateTime.now(),
                name,
                newStatus,
              );
          ref.read(todayPrayerRecordProvider.notifier).markCompleted(
                name,
                status: newStatus,
              );
          setModalState(() {});
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(isSelected
                  ? '$name ${ctx.tr('clear_prayer_status').toLowerCase()}'
                  : '$name marked as $label'),
              duration: const Duration(seconds: 2),
              backgroundColor: isSelected ? AppColors.surfaceHighlight : color,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.surfaceHighlight,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWindowInspectionModal({
    required BuildContext context,
    required String title,
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required GamingStatus status,
    required List<GameProfile> userGames,
    bool is24Hour = false,
  }) {
    // Find games that fit comfortably in this slot
    final playableGames = userGames.where((g) {
      return g.enabledModes.any((m) => m.minMinutes <= durationMinutes);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sports_esports_rounded, color: status.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        '${TimeUtils.formatTime(startTime, is24Hour: is24Hour)} – ${TimeUtils.formatTime(endTime, is24Hour: is24Hour)} (${TimeUtils.formatMinutes(durationMinutes)} available)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              status == GamingStatus.safe
                  ? 'Safe for full ranked matches, competitive queues, and standard gaming sessions.'
                  : 'Safe only for quick arcade modes (Swiftplay, ARAM, Casual) or pauseable titles.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (playableGames.isNotEmpty) ...[
              const Text(
                'PLAYABLE FROM YOUR LIBRARY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: playableGames.take(6).map((game) {
                  return Chip(
                    avatar: GameIconWidget(iconName: game.iconName, size: 20, fallbackColor: game.color),
                    label: Text(game.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                    side: BorderSide(color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiveNeedle extends ConsumerWidget {
  final double width;
  final double totalMinutes;

  const _LiveNeedle({required this.width, required this.totalMinutes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when the 1-second live ticker fires
    final nowAsync = ref.watch(liveSecondTickerProvider);
    final now = nowAsync.value ?? DateTime.now();

    final nowMinutes = now.hour * 60.0 + now.minute + now.second / 60.0;
    final nowFraction = (nowMinutes / totalMinutes).clamp(0.0, 1.0);
    final posX = (nowFraction * width).clamp(0.0, width);

    return Positioned(
      left: (posX - 14).clamp(0.0, width - 28.0),
      top: 0,
      bottom: 0,
      width: 28,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.dangerRed,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dangerRed.withValues(alpha: 0.5),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Text(
              'NOW',
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dangerRed.withValues(alpha: 0.6),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final Color primaryColor;

  const _LiveBadge({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'LIVE 24H',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
