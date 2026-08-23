import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/models/prayer_record.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';
import '../../../core/providers/prayer_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/desktop_service.dart';
import '../../../core/services/home_widget_service.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/risk_calculator.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_logo_widget.dart';
import '../../../core/widgets/game_icon_widget.dart';
import '../../home/widgets/next_prayer_hero_widget.dart';
import '../../home/widgets/prayer_gaming_timeline_widget.dart';

class QueueCheckScreen extends ConsumerStatefulWidget {
  const QueueCheckScreen({super.key});

  @override
  ConsumerState<QueueCheckScreen> createState() => _QueueCheckScreenState();
}

class _QueueCheckScreenState extends ConsumerState<QueueCheckScreen> {
  int? _desiredSessionMinutes; // Default null = Open session (until next prayer)
  String _selectedGameFilter = 'all';
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = StorageService.cityName;
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final userGames = ref.watch(activeSelectedGamesProvider);
    final activeTheme = Theme.of(context);
    final primaryColor = activeTheme.primaryColor;

    final nextPrayerName = nextPrayer?.key ?? '';
    final nextPrayerTime = nextPrayer?.value;
    final minutesUntilPrayer = nextPrayerTime != null
        ? nextPrayerTime.difference(DateTime.now()).inMinutes
        : 999;
    final verdict = minutesUntilPrayer > bufferMinutes
        ? ref.tr('safe_to_play_short')
        : ref.tr('caution_wrap_up');

    // Sync data with widgets & tray
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nextPrayer != null) {
        HomeWidgetService.updateWidgets(
          nextPrayerName: nextPrayer.key,
          nextPrayerTime: nextPrayer.value,
        );
        if (DesktopService.isDesktop) {
          DesktopService.instance.updateTrayMenu(
            nextPrayerName: nextPrayer.key,
            nextPrayerTime: TimeUtils.formatTime(nextPrayer.value),
            verdict: verdict,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: activeTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const AppLogoWidget(
                      variant: AppLogoVariant.iconOnly,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  city.isNotEmpty
                                      ? city
                                      : context.tr('location_configured'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded,
                              size: 12, color: primaryColor),
                          const SizedBox(width: 3),
                          Text(
                            TimeUtils.formatMinutes(bufferMinutes),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Next Prayer Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: NextPrayerHeroWidget(
                  prayerName: nextPrayerName,
                  prayerTime: nextPrayerTime,
                  bufferMinutes: bufferMinutes,
                ),
              ),
            ),

            // 24H Salah Timeline ("Where Are We Now?")
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: PrayerGamingTimelineWidget(),
              ),
            ),

            // Session Duration Selector ("How long do you want to play?")
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.primaryCyan),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('how_long_play').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _desiredSessionMinutes == null
                                  ? (nextPrayerName.isNotEmpty &&
                                          minutesUntilPrayer > 0
                                      ? '${context.tr('duration_open')} (${context.tr('prayer_${nextPrayerName.toLowerCase()}')} • ${TimeUtils.formatMinutes(minutesUntilPrayer)})'
                                      : context.tr('duration_open'))
                                  : TimeUtils.formatMinutes(
                                      _desiredSessionMinutes!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildOpenChip(
                          openMinutes: minutesUntilPrayer > 0
                              ? minutesUntilPrayer
                              : null,
                          nextPrayerName: nextPrayerName,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(30),
                          minutes: 30,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(60),
                          minutes: 60,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(120),
                          minutes: 120,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(180),
                          minutes: 180,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(240),
                          minutes: 240,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(360),
                          minutes: 360,
                        ),
                        _buildPresetChip(
                          label: TimeUtils.formatMinutes(480),
                          minutes: 480,
                        ),
                        _buildCustomChip(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Active Dynamic Session Timeline (Updates based on chosen duration)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildDynamicSessionTimeline(
                  bufferMinutes: bufferMinutes,
                  nextPrayerName: nextPrayerName,
                  nextPrayerTime: nextPrayerTime,
                ),
              ),
            ),

            // Categorized Games (Recommended, Caution, Not Recommended)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: _buildCategorizedGames(
                  userGames: userGames,
                  minutesUntilPrayer: minutesUntilPrayer,
                  bufferMinutes: bufferMinutes,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenChip({int? openMinutes, String? nextPrayerName}) {
    final isSelected = _desiredSessionMinutes == null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final surfaceColor = theme.colorScheme.surface;
    final surfaceHighlight =
        theme.dividerTheme.color ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));

    final prayerLabel = (nextPrayerName != null && nextPrayerName.isNotEmpty)
        ? context.tr('prayer_${nextPrayerName.toLowerCase()}')
        : null;
    final untilText = prayerLabel != null && openMinutes != null
        ? '${context.tr('duration_open')} ($prayerLabel • ${TimeUtils.formatMinutes(openMinutes)})'
        : context.tr('duration_open');

    return GestureDetector(
      onTap: () => setState(() => _desiredSessionMinutes = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
              : surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : surfaceHighlight,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.all_inclusive_rounded,
              size: 13,
              color: isSelected ? primaryColor : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                untilText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isSelected ? primaryColor : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({required String label, required int minutes}) {
    final isSelected = _desiredSessionMinutes == minutes;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final surfaceColor = theme.colorScheme.surface;
    final surfaceHighlight =
        theme.dividerTheme.color ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));

    return GestureDetector(
      onTap: () => setState(() => _desiredSessionMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
              : surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : surfaceHighlight,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? primaryColor : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final isPreset = [30, 60, 120, 180, 240, 360, 480].contains(_desiredSessionMinutes);
    final isCustom = _desiredSessionMinutes != null && !isPreset;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final surfaceColor = theme.colorScheme.surface;
    final surfaceHighlight =
        theme.dividerTheme.color ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));

    return GestureDetector(
      onTap: () => _showCustomDurationBottomSheet(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isCustom
              ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
              : surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCustom ? primaryColor : surfaceHighlight,
            width: isCustom ? 1.4 : 1,
          ),
          boxShadow: isCustom
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 12,
              color: isCustom ? primaryColor : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              isCustom
                  ? TimeUtils.formatMinutes(_desiredSessionMinutes!)
                  : context.tr('duration_custom'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isCustom ? FontWeight.w800 : FontWeight.w600,
                color: isCustom ? primaryColor : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDurationBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = Theme.of(context).primaryColor;
          final surfaceColor = Theme.of(context).colorScheme.surface;

          double currentMinutes =
              (_desiredSessionMinutes ?? 60).toDouble().clamp(15, 720);

          final quickSteps = [15, 60, 120, 180, 240, 360, 480, 720];

          return Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ??
                    (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimal handle bar
                  Center(
                    child: Container(
                      width: 32,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Compact Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('custom_duration_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.35),
                            width: 0.9,
                          ),
                        ),
                        child: Text(
                          TimeUtils.formatMinutes(currentMinutes.round()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Compact Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: primaryColor.withValues(alpha: 0.15),
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withValues(alpha: 0.12),
                      trackHeight: 3.5,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: currentMinutes,
                      min: 15,
                      max: 720,
                      divisions: 47,
                      onChanged: (val) {
                        final rounded = (val / 15).round() * 15;
                        setSheetState(() => currentMinutes = rounded.toDouble());
                        setState(() => _desiredSessionMinutes = rounded);
                      },
                    ),
                  ),

                  // Quick Step Pills Row
                  SizedBox(
                    height: 26,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: quickSteps.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final mins = quickSteps[idx];
                        final isAct = currentMinutes.round() == mins;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() => currentMinutes = mins.toDouble());
                            setState(() => _desiredSessionMinutes = mins);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAct
                                  ? primaryColor.withValues(alpha: 0.18)
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isAct
                                    ? primaryColor
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0)),
                                width: isAct ? 1.2 : 0.8,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                TimeUtils.formatMinutes(mins),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      isAct ? FontWeight.w800 : FontWeight.w600,
                                  color: isAct
                                      ? primaryColor
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Compact Set Duration Button
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        context.tr('set_duration_btn'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicSessionTimeline({
    required int bufferMinutes,
    required String nextPrayerName,
    required DateTime? nextPrayerTime,
  }) {
    final now = DateTime.now();
    final isOpenSession = _desiredSessionMinutes == null;

    final is24Hour = StorageService.is24HourFormat;
    final timeFormat = DateFormat(is24Hour ? 'HH:mm' : 'h:mm a');
    final userGames = ref.watch(userGamesProvider);

    // Retrieve today's and tomorrow's upcoming prayer times
    final prayerTimes = ref.watch(dailyPrayerTimesProvider);
    final allUpcomingPrayers = <MapEntry<String, DateTime>>[];

    if (prayerTimes != null) {
      // Add today's prayers (including active prayer within its 15m break)
      for (final entry in prayerTimes.allPrayers) {
        if (entry.key.toLowerCase() == 'sunrise') continue;
        if (entry.value.isAfter(now.subtract(const Duration(minutes: 15)))) {
          allUpcomingPrayers.add(entry);
        }
      }

      // Add tomorrow's prayers for continuous timeline horizon
      final tomorrow = now.add(const Duration(days: 1));
      final lat = StorageService.latitude ?? 21.4225;
      final lng = StorageService.longitude ?? 39.8262;
      final method = ref.watch(calculationMethodProvider);
      final asrMethod = ref.watch(asrMethodProvider);
      final tomorrowPrayers = PrayerService.calculatePrayerTimes(
        latitude: lat,
        longitude: lng,
        date: tomorrow,
        method: method,
        asrMethod: asrMethod,
      );
      for (final entry in tomorrowPrayers.allPrayers) {
        if (entry.key.toLowerCase() == 'sunrise') continue;
        allUpcomingPrayers.add(entry);
      }
    }

    final firstPrayer =
        allUpcomingPrayers.isNotEmpty ? allUpcomingPrayers.first : null;
    final int minsToFirst =
        firstPrayer != null ? firstPrayer.value.difference(now).inMinutes : 9999;
    // Prayer is at the very start if it's within buffer, within 15 mins, or currently active (<= 0)
    final bool isFirstPrayerAtStart =
        firstPrayer != null && (minsToFirst <= bufferMinutes || minsToFirst <= 15);

    MapEntry<String, DateTime>? targetEndPrayer;
    DateTime sessionEndTime;
    int plannedDuration;
    final prayersInTimeline = <MapEntry<String, DateTime>>[];

    if (isOpenSession) {
      if (isFirstPrayerAtStart && allUpcomingPrayers.length >= 2) {
        // First prayer is at the very start -> Timeline shows 2 prayers (first at start, second at end!)
        prayersInTimeline.add(allUpcomingPrayers[0]);
        prayersInTimeline.add(allUpcomingPrayers[1]);
        targetEndPrayer = allUpcomingPrayers[1];
        sessionEndTime =
            targetEndPrayer.value.subtract(Duration(minutes: bufferMinutes));
        plannedDuration =
            sessionEndTime.difference(now).inMinutes.clamp(1, 1440);
      } else if (firstPrayer != null) {
        // First prayer is in the future -> Timeline shows 1 prayer at the end!
        prayersInTimeline.add(firstPrayer);
        targetEndPrayer = firstPrayer;
        sessionEndTime =
            targetEndPrayer.value.subtract(Duration(minutes: bufferMinutes));
        plannedDuration =
            sessionEndTime.difference(now).inMinutes.clamp(1, 1440);
      } else {
        plannedDuration = 60;
        sessionEndTime = now.add(Duration(minutes: plannedDuration));
      }
    } else {
      plannedDuration = _desiredSessionMinutes!;
      sessionEndTime = now.add(Duration(minutes: plannedDuration));
      for (final p in allUpcomingPrayers) {
        if (p.value.isBefore(sessionEndTime) ||
            (prayersInTimeline.isEmpty &&
                p.value.isBefore(
                    sessionEndTime.add(const Duration(minutes: 15))))) {
          prayersInTimeline.add(p);
        }
      }
      targetEndPrayer = prayersInTimeline.isNotEmpty
          ? prayersInTimeline.last
          : firstPrayer;
    }

    final hasPrayerBreak = prayersInTimeline.isNotEmpty;
    final isOverrunningNext = targetEndPrayer != null &&
        sessionEndTime.isAfter(
            targetEndPrayer.value.subtract(Duration(minutes: bufferMinutes)));

    final statusColor = hasPrayerBreak || isOverrunningNext
        ? AppColors.primaryCyan
        : AppColors.successGreen;

    // Build Proportional Visual Duration Segments (Gaming vs Prayer Breaks)
    final sessionSegments = <({
      String type,
      int duration,
      DateTime startTime,
      DateTime endTime,
      String label,
      Color color,
      IconData icon,
      String? prayerName,
    })>[];
    DateTime cursorTime = now;

    if (prayersInTimeline.isNotEmpty) {
      for (final prayer in prayersInTimeline) {
        final playMinutes = prayer.value.difference(cursorTime).inMinutes;
        if (playMinutes > 0) {
          sessionSegments.add((
            type: 'play',
            duration: playMinutes,
            startTime: cursorTime,
            endTime: prayer.value,
            label: TimeUtils.formatMinutes(playMinutes),
            color: AppColors.primaryCyan,
            icon: Icons.sports_esports_rounded,
            prayerName: null,
          ));
        }

        const prayerBreakMinutes = 15;
        final prayerLabel = context.tr('prayer_${prayer.key.toLowerCase()}');
        final breakStartTime = prayer.value;
        final breakEndTime =
            breakStartTime.add(const Duration(minutes: prayerBreakMinutes));

        sessionSegments.add((
          type: 'prayer',
          duration: prayerBreakMinutes,
          startTime: breakStartTime,
          endTime: breakEndTime,
          label: '$prayerLabel (15m)',
          color: AppColors.warningAmber,
          icon: Icons.mosque_rounded,
          prayerName: prayer.key,
        ));

        cursorTime = breakEndTime;
      }

      if (sessionEndTime.isAfter(cursorTime)) {
        final remainingPlay = sessionEndTime.difference(cursorTime).inMinutes;
        if (remainingPlay > 0) {
          sessionSegments.add((
            type: 'play',
            duration: remainingPlay,
            startTime: cursorTime,
            endTime: sessionEndTime,
            label: TimeUtils.formatMinutes(remainingPlay),
            color: AppColors.primaryCyan,
            icon: Icons.sports_esports_rounded,
            prayerName: null,
          ));
        }
      }
    } else {
      sessionSegments.add((
        type: 'play',
        duration: plannedDuration,
        startTime: now,
        endTime: sessionEndTime,
        label: '${TimeUtils.formatMinutes(plannedDuration)} Play',
        color: AppColors.successGreen,
        icon: Icons.sports_esports_rounded,
        prayerName: null,
      ));
    }

    final totalSegMinutes =
        sessionSegments.fold<int>(0, (sum, s) => sum + s.duration);
    final totalGamingMinutes = sessionSegments
        .where((s) => s.type == 'play')
        .fold<int>(0, (sum, s) => sum + s.duration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 15, color: statusColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  context.tr('timeline_title').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOpenSession
                        ? (targetEndPrayer != null
                            ? 'Until ${context.tr('prayer_${targetEndPrayer.key.toLowerCase()}')} (${TimeUtils.formatMinutes(plannedDuration)})'
                            : context.tr('duration_open'))
                        : '${TimeUtils.formatMinutes(plannedDuration)} Planned',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Proportional Duration Visualizer Bar (Interactive Tappable Segments)
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.surfaceHighlight.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              children: sessionSegments.map((seg) {
                final pct = totalSegMinutes > 0
                    ? (seg.duration / totalSegMinutes * 100).round()
                    : 100;
                final flex = seg.type == 'prayer'
                    ? seg.duration.clamp(20, 99999)
                    : seg.duration.clamp(15, 99999);

                return Expanded(
                  flex: flex,
                  child: InkWell(
                    onTap: () {
                      if (seg.type == 'prayer') {
                        _showPrayerInfoModal(
                          context: context,
                          ref: ref,
                          name: seg.prayerName ?? 'Prayer',
                          time: seg.startTime,
                          breakMinutes: seg.duration,
                          is24Hour: is24Hour,
                        );
                      } else {
                        _showWindowInspectionModal(
                          context: context,
                          title:
                              '${timeFormat.format(seg.startTime)} ➔ ${timeFormat.format(seg.endTime)} Gaming Window',
                          durationMinutes: seg.duration,
                          startTime: seg.startTime,
                          endTime: seg.endTime,
                          status: GamingStatus.safe,
                          userGames: userGames,
                          is24Hour: is24Hour,
                        );
                      }
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        Widget inner;
                        if (w >= 75) {
                          inner = FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(seg.icon, size: 11, color: seg.color),
                                  const SizedBox(width: 3),
                                  Text(
                                    seg.type == 'prayer'
                                        ? seg.label
                                        : '${seg.label} ($pct%)',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: seg.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (w >= 36) {
                          inner = FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(seg.icon, size: 10, color: seg.color),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$pct%',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: seg.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (w >= 14) {
                          inner = FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(seg.icon,
                                  size: 10, color: seg.color),
                            ),
                          );
                        } else {
                          inner = const SizedBox.shrink();
                        }

                        return Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: seg.color.withValues(
                                alpha: seg.type == 'prayer' ? 0.22 : 0.14),
                            border: Border(
                              left: BorderSide(
                                  color: seg.color.withValues(alpha: 0.7),
                                  width: 1.0),
                              right: BorderSide(
                                  color: seg.color.withValues(alpha: 0.7),
                                  width: 1.0),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Tooltip(
                            message:
                                '${seg.label} • $pct% (Tap for details)',
                            child: Center(child: inner),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Synchronized Proportional Multi-Milestone Flow (Adaptive Density & Responsive Typography)
          Builder(
            builder: (context) {
              final prayerCount = sessionSegments
                  .where((s) => s.type == 'prayer')
                  .length;
              final isCrowded = prayerCount >= 3;
              final isMedium = prayerCount == 2;

              final double circleSize =
                  isCrowded ? 18.0 : (isMedium ? 19.5 : 21.0);
              final double iconSize =
                  isCrowded ? 8.5 : (isMedium ? 9.2 : 10.0);
              final double timeFontSize =
                  isCrowded ? 8.0 : (isMedium ? 8.5 : 9.0);
              final double labelFontSize =
                  isCrowded ? 7.0 : (isMedium ? 7.5 : 8.0);
              final double sublabelFontSize =
                  isCrowded ? 6.0 : (isMedium ? 6.5 : 7.0);
              final double nodeMaxWidth = isCrowded ? 56.0 : 64.0;
              final double lineTop = (circleSize / 2.0) - 1.0;
              final double circleCenterOffset = circleSize / 2.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sessionSegments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final seg = entry.value;
                  final isFirst = index == 0;
                  final isLast = index == sessionSegments.length - 1;
                  final flex = seg.type == 'prayer'
                      ? seg.duration.clamp(20, 99999)
                      : seg.duration.clamp(15, 99999);

                  if (seg.type == 'prayer') {
                    final prayerNameTranslated = seg.prayerName != null
                        ? context.tr('prayer_${seg.prayerName!.toLowerCase()}')
                        : 'Prayer';

                    final nodeWidget = _buildMilestoneNode(
                      label: context.trFormat('prayer_break_title', {
                        'prayer': prayerNameTranslated,
                      }),
                      time: timeFormat.format(seg.startTime),
                      sublabel: context.trFormat('minutes_break_short', {
                        'minutes': seg.duration.toString(),
                      }),
                      color: AppColors.warningAmber,
                      icon: Icons.mosque_rounded,
                      alignment: isFirst
                          ? CrossAxisAlignment.start
                          : (isLast
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.center),
                      textAlign: isFirst
                          ? TextAlign.start
                          : (isLast ? TextAlign.end : TextAlign.center),
                      maxWidth: nodeMaxWidth,
                      circleSize: circleSize,
                      iconSize: iconSize,
                      timeFontSize: timeFontSize,
                      labelFontSize: labelFontSize,
                      sublabelFontSize: sublabelFontSize,
                      onTap: () => _showPrayerInfoModal(
                        context: context,
                        ref: ref,
                        name: seg.prayerName ?? 'Prayer',
                        time: seg.startTime,
                        breakMinutes: seg.duration,
                        is24Hour: is24Hour,
                      ),
                    );

                    return Expanded(
                      flex: flex,
                      child: SizedBox(
                        height: 64,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: isFirst ? circleCenterOffset : 0,
                              right: isLast ? circleCenterOffset : 0,
                              top: lineTop,
                              child: Container(
                                height: 2.0,
                                color: AppColors.primaryCyan
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            if (isFirst)
                              Positioned(
                                left: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: nodeWidget,
                              )
                            else if (isLast)
                              Positioned(
                                right: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: nodeWidget,
                              )
                            else
                              Center(
                                child: SizedBox(
                                  width: nodeMaxWidth,
                                  child: nodeWidget,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Play Segment
                    if (isFirst && isLast) {
                      // Single window session
                      return Expanded(
                        flex: flex,
                        child: SizedBox(
                          height: 64,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: circleCenterOffset,
                                right: circleCenterOffset,
                                top: lineTop,
                                child: Container(
                                  height: 2.0,
                                  color: AppColors.successGreen
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              Positioned(
                                left: circleSize + 4.0,
                                right: circleSize + 4.0,
                                top: lineTop - 7.5,
                                child: Center(
                                  child: _buildTimelineBadge(
                                    color: AppColors.successGreen,
                                    durationMinutes: seg.duration,
                                    isCrowded: isCrowded,
                                    customLabel:
                                        context.tr('timeline_resume'),
                                    onTap: () =>
                                        _showWindowInspectionModal(
                                      context: context,
                                      title:
                                          '${timeFormat.format(seg.startTime)} ➔ ${timeFormat.format(seg.endTime)} Gaming Window',
                                      durationMinutes: seg.duration,
                                      startTime: seg.startTime,
                                      endTime: seg.endTime,
                                      status: GamingStatus.safe,
                                      userGames: userGames,
                                      is24Hour: is24Hour,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: _buildMilestoneNode(
                                  label: context.tr('timeline_now'),
                                  time: timeFormat.format(seg.startTime),
                                  color: AppColors.primaryCyan,
                                  icon: Icons.sports_esports_rounded,
                                  alignment: CrossAxisAlignment.start,
                                  textAlign: TextAlign.start,
                                  maxWidth: nodeMaxWidth,
                                  circleSize: circleSize,
                                  iconSize: iconSize,
                                  timeFontSize: timeFontSize,
                                  labelFontSize: labelFontSize,
                                  sublabelFontSize: sublabelFontSize,
                                  onTap: () => _showSessionSummaryModal(
                                    context: context,
                                    startTime: now,
                                    endTime: sessionEndTime,
                                    plannedDuration: plannedDuration,
                                    isOpenSession: isOpenSession,
                                    gamingMinutes: totalGamingMinutes,
                                    prayerCount:
                                        prayersInTimeline.length,
                                    is24Hour: is24Hour,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: _buildMilestoneNode(
                                  label: context.tr('timeline_session_end'),
                                  time: timeFormat.format(seg.endTime),
                                  color: AppColors.successGreen,
                                  icon: Icons.check_circle_rounded,
                                  alignment: CrossAxisAlignment.end,
                                  textAlign: TextAlign.end,
                                  maxWidth: nodeMaxWidth,
                                  circleSize: circleSize,
                                  iconSize: iconSize,
                                  timeFontSize: timeFontSize,
                                  labelFontSize: labelFontSize,
                                  sublabelFontSize: sublabelFontSize,
                                  onTap: () => _showSessionSummaryModal(
                                    context: context,
                                    startTime: now,
                                    endTime: sessionEndTime,
                                    plannedDuration: plannedDuration,
                                    isOpenSession: isOpenSession,
                                    gamingMinutes: totalGamingMinutes,
                                    prayerCount:
                                        prayersInTimeline.length,
                                    is24Hour: is24Hour,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (isFirst) {
                      // First play window leading up to first prayer
                      return Expanded(
                        flex: flex,
                        child: SizedBox(
                          height: 64,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: circleCenterOffset,
                                right: 0,
                                top: lineTop,
                                child: Container(
                                  height: 2.0,
                                  color: AppColors.primaryCyan
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              Positioned(
                                left: circleSize + 2.0,
                                right: 0,
                                top: lineTop - 7.5,
                                child: Center(
                                  child: _buildTimelineBadge(
                                    color: AppColors.primaryCyan,
                                    durationMinutes: seg.duration,
                                    isCrowded: isCrowded,
                                    customLabel:
                                        context.tr('timeline_resume'),
                                    onTap: () =>
                                        _showWindowInspectionModal(
                                      context: context,
                                      title: context.trFormat(
                                        'gaming_window_title_format',
                                        {
                                          'start': timeFormat.format(seg.startTime),
                                          'end': timeFormat.format(seg.endTime),
                                        },
                                      ),
                                      durationMinutes: seg.duration,
                                      startTime: seg.startTime,
                                      endTime: seg.endTime,
                                      status: GamingStatus.safe,
                                      userGames: userGames,
                                      is24Hour: is24Hour,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: _buildMilestoneNode(
                                  label: context.tr('timeline_now'),
                                  time: timeFormat.format(seg.startTime),
                                  color: AppColors.primaryCyan,
                                  icon: Icons.sports_esports_rounded,
                                  alignment: CrossAxisAlignment.start,
                                  textAlign: TextAlign.start,
                                  maxWidth: nodeMaxWidth,
                                  circleSize: circleSize,
                                  iconSize: iconSize,
                                  timeFontSize: timeFontSize,
                                  labelFontSize: labelFontSize,
                                  sublabelFontSize: sublabelFontSize,
                                  onTap: () => _showSessionSummaryModal(
                                    context: context,
                                    startTime: now,
                                    endTime: sessionEndTime,
                                    plannedDuration: plannedDuration,
                                    isOpenSession: isOpenSession,
                                    gamingMinutes: totalGamingMinutes,
                                    prayerCount:
                                        prayersInTimeline.length,
                                    is24Hour: is24Hour,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (isLast) {
                      // Final play window ending at session end
                      return Expanded(
                        flex: flex,
                        child: SizedBox(
                          height: 64,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                right: circleCenterOffset,
                                top: lineTop,
                                child: Container(
                                  height: 2.0,
                                  color: AppColors.primaryCyan
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: circleSize + 2.0,
                                top: lineTop - 7.5,
                                child: Center(
                                  child: _buildTimelineBadge(
                                    color: AppColors.primaryCyan,
                                    durationMinutes: seg.duration,
                                    isCrowded: isCrowded,
                                    customLabel:
                                        context.tr('timeline_resume'),
                                    onTap: () =>
                                        _showWindowInspectionModal(
                                      context: context,
                                      title: context.trFormat(
                                        'gaming_window_title_format',
                                        {
                                          'start': timeFormat.format(seg.startTime),
                                          'end': timeFormat.format(seg.endTime),
                                        },
                                      ),
                                      durationMinutes: seg.duration,
                                      startTime: seg.startTime,
                                      endTime: seg.endTime,
                                      status: GamingStatus.safe,
                                      userGames: userGames,
                                      is24Hour: is24Hour,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                width: nodeMaxWidth,
                                child: _buildMilestoneNode(
                                  label: context.tr('timeline_session_end'),
                                  time: timeFormat.format(seg.endTime),
                                  color: AppColors.primaryCyan,
                                  icon: Icons.sports_esports_rounded,
                                  alignment: CrossAxisAlignment.end,
                                  textAlign: TextAlign.end,
                                  maxWidth: nodeMaxWidth,
                                  circleSize: circleSize,
                                  iconSize: iconSize,
                                  timeFontSize: timeFontSize,
                                  labelFontSize: labelFontSize,
                                  sublabelFontSize: sublabelFontSize,
                                  onTap: () => _showSessionSummaryModal(
                                    context: context,
                                    startTime: now,
                                    endTime: sessionEndTime,
                                    plannedDuration: plannedDuration,
                                    isOpenSession: isOpenSession,
                                    gamingMinutes: totalGamingMinutes,
                                    prayerCount:
                                        prayersInTimeline.length,
                                    is24Hour: is24Hour,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Intermediate play window
                      return Expanded(
                        flex: flex,
                        child: SizedBox(
                          height: 64,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: lineTop,
                                child: Container(
                                  height: 2.0,
                                  color: AppColors.primaryCyan
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                top: lineTop - 7.5,
                                child: Center(
                                  child: _buildTimelineBadge(
                                    color: AppColors.primaryCyan,
                                    durationMinutes: seg.duration,
                                    isCrowded: isCrowded,
                                    customLabel:
                                        context.tr('timeline_resume'),
                                    onTap: () =>
                                        _showWindowInspectionModal(
                                      context: context,
                                      title: context.trFormat(
                                        'gaming_window_title_format',
                                        {
                                          'start': timeFormat.format(seg.startTime),
                                          'end': timeFormat.format(seg.endTime),
                                        },
                                      ),
                                      durationMinutes: seg.duration,
                                      startTime: seg.startTime,
                                      endTime: seg.endTime,
                                      status: GamingStatus.safe,
                                      userGames: userGames,
                                      is24Hour: is24Hour,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode({
    required String label,
    required String time,
    String? sublabel,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
    TextAlign textAlign = TextAlign.center,
    double? maxWidth,
    double circleSize = 20.0,
    double iconSize = 9.5,
    double timeFontSize = 9.0,
    double labelFontSize = 7.5,
    double sublabelFontSize = 6.5,
  }) {
    final nodeContent = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                color.withValues(alpha: 0.18),
                Theme.of(context).colorScheme.surface,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 3.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: color,
            ),
          ),
          const SizedBox(height: 2.5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: timeFontSize,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          if (sublabel != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sublabel,
                maxLines: 1,
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: sublabelFontSize,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: nodeContent,
      );
    }
    return nodeContent;
  }

  Widget _buildTimelineBadge({
    required Color color,
    int? durationMinutes,
    String? customLabel,
    bool isCrowded = false,
    VoidCallback? onTap,
  }) {
    if (durationMinutes == null || durationMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final badgeContent = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w < 14) return const SizedBox.shrink();

        final formatted = TimeUtils.formatMinutes(durationMinutes);
        String text;
        if (w >= 75 && !isCrowded) {
          text = customLabel != null ? '$formatted • $customLabel' : formatted;
        } else {
          text = formatted;
        }

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: isCrowded ? 4.0 : 5.0,
              vertical: isCrowded ? 1.0 : 1.5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (w - 2).clamp(8.0, 9999.0),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (w >= 48 && !isCrowded) ...[
                    Icon(
                      Icons.sports_esports_rounded,
                      size: 8.5,
                      color: color,
                    ),
                    const SizedBox(width: 2.0),
                  ],
                  Text(
                    text,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isCrowded ? 7.0 : 7.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: badgeContent,
      );
    }
    return badgeContent;
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
                  child: Icon(Icons.sports_esports_rounded,
                      color: status.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
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
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (playableGames.isNotEmpty) ...[
              const Text(
                'PLAYABLE FROM YOUR LIBRARY',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: playableGames.take(6).map((game) {
                  return Chip(
                    avatar: GameIconWidget(
                        iconName: game.iconName,
                        size: 20,
                        fallbackColor: game.color),
                    label: Text(game.name,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            AppColors.surfaceElevated,
                    side: BorderSide(
                        color: Theme.of(context).dividerTheme.color ??
                            AppColors.surfaceHighlight,
                        width: 0.8),
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

  void _showPrayerInfoModal({
    required BuildContext context,
    required WidgetRef ref,
    required String name,
    required DateTime time,
    int breakMinutes = 15,
    bool is24Hour = false,
  }) {
    final activeTheme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: activeTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final liveRecord = ref
              .read(prayerConsistencyProvider.notifier)
              .getRecord(DateTime.now());
          final activeStatus =
              liveRecord.prayers[name] ?? PrayerStatus.notRecorded;
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
                        color: AppColors.warningAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.mosque_rounded,
                          color: AppColors.warningAmber, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.trFormat('prayer_break_title', {
                              'prayer': context.tr('prayer_${name.toLowerCase()}'),
                            }),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${TimeUtils.formatTime(time, is24Hour: is24Hour)} – ${TimeUtils.formatTime(time.add(Duration(minutes: breakMinutes)), is24Hour: is24Hour)} ${context.trFormat('prayer_buffer_sub', {'minutes': breakMinutes.toString()})}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                          Icon(activeStatus.icon,
                              size: 14, color: activeStatus.color),
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
                  Builder(
                    builder: (context) {
                      final diffMinutes = time.difference(DateTime.now()).inMinutes;
                      final timeLeftStr = diffMinutes > 0
                          ? TimeUtils.formatMinutes(diffMinutes)
                          : '';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryCyan.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (diffMinutes > 0) ...[
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      size: 15, color: AppColors.primaryCyan),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.trFormat('minutes_left_until_prayer', {
                                      'time': timeLeftStr,
                                    }),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryCyan,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            Row(
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
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  context.trFormat('prayer_guidance_prompt', {
                    'prayer': context.tr('prayer_${name.toLowerCase()}'),
                  }),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('mark_prayer_status_title'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPrayerLogButton(
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
                    _buildPrayerLogButton(
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
                    _buildPrayerLogButton(
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
                        ref
                            .read(prayerConsistencyProvider.notifier)
                            .updatePrayerStatus(
                              DateTime.now(),
                              name,
                              PrayerStatus.notRecorded,
                            );
                        ref
                            .read(todayPrayerRecordProvider.notifier)
                            .markCompleted(
                              name,
                              status: PrayerStatus.notRecorded,
                            );
                        setModalState(() {});
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$name ${context.tr('clear_prayer_status').toLowerCase()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded,
                          size: 16, color: AppColors.textMuted),
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

  Widget _buildPrayerLogButton({
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
          final newStatus =
              isSelected ? PrayerStatus.notRecorded : targetStatus;
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
                  color:
                      isSelected ? color : Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionSummaryModal({
    required BuildContext context,
    required DateTime startTime,
    required DateTime endTime,
    required int plannedDuration,
    required bool isOpenSession,
    required int gamingMinutes,
    required int prayerCount,
    bool is24Hour = false,
  }) {
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
                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.timer_outlined,
                      color: AppColors.primaryCyan, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOpenSession
                            ? 'Open Session Plan'
                            : '${TimeUtils.formatMinutes(plannedDuration)} Session Plan',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${TimeUtils.formatTime(startTime, is24Hour: is24Hour)} – ${TimeUtils.formatTime(endTime, is24Hour: is24Hour)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryCyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.surfaceHighlight,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL GAMING TIME',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          TimeUtils.formatMinutes(gamingMinutes),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.surfaceHighlight,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRAYER BREAKS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prayerCount == 0
                              ? 'Zero breaks'
                              : '$prayerCount break${prayerCount > 1 ? 's' : ''} (15m ea)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: prayerCount > 0
                                ? AppColors.warningAmber
                                : AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedGames({
    required List<GameProfile> userGames,
    required int minutesUntilPrayer,
    required int bufferMinutes,
  }) {
    if (userGames.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: GlassmorphicDecoration.card(context: context),
        child: Column(
          children: [
            const Icon(Icons.sports_esports_outlined,
                size: 36, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              context.tr('no_games_selected_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('no_games_selected_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    // Filter games based on the selected game filter tab
    final evaluatingGames = _selectedGameFilter == 'all'
        ? userGames
        : userGames.where((g) => g.id == _selectedGameFilter).toList();

    final recommendedNow =
        <({GameProfile game, GameActivity activity, RiskLevel risk})>[];
    final useCaution =
        <({GameProfile game, GameActivity activity, RiskLevel risk})>[];
    final notRecommended =
        <({GameProfile game, GameActivity activity, RiskLevel risk})>[];

    for (final game in evaluatingGames) {
      for (final activity in game.enabledActivities) {
        final effectiveBuffer = activity.safetyBuffer ?? bufferMinutes;
        final risk = RiskCalculator.calculateRisk(
          activity,
          minutesUntilPrayer,
          bufferMinutes: effectiveBuffer,
          desiredSessionMinutes: _desiredSessionMinutes,
        );

        final item = (game: game, activity: activity, risk: risk);

        if (activity.canPause && !activity.requiresCompletion) {
          recommendedNow.add(item);
        } else if (risk == RiskLevel.low) {
          recommendedNow.add(item);
        } else if (risk == RiskLevel.medium) {
          useCaution.add(item);
        } else {
          notRecommended.add(item);
        }
      }
    }

    final allGamesCount =
        userGames.fold<int>(0, (sum, g) => sum + g.enabledActivities.length);
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive Game Filter Tab Navigation Bar (Wrap prevents edge clipping)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildGameFilterTab(
              id: 'all',
              label: context.tr('tab_all_games'),
              icon: Icons.sports_esports_rounded,
              count: allGamesCount,
              isSelected: _selectedGameFilter == 'all',
              primaryColor: primaryColor,
            ),
            ...userGames.map((game) => _buildGameFilterTab(
                  id: game.id,
                  label: game.name,
                  iconName: game.iconName,
                  fallbackColor: game.color,
                  count: game.enabledActivities.length,
                  isSelected: _selectedGameFilter == game.id,
                  primaryColor: primaryColor,
                )),
          ],
        ),
        const SizedBox(height: 14),

        // Recommended now
        if (recommendedNow.isNotEmpty) ...[
          _buildCategoryHeader(
            icon: Icons.check_circle_rounded,
            title: context.tr('rec_now_title'),
            subtitle: context.tr('rec_now_sub'),
            color: AppColors.successGreen,
            count: recommendedNow.length,
          ),
          const SizedBox(height: 8),
          ...recommendedNow.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGameCard(item: item),
              )),
          const SizedBox(height: 16),
        ],

        // Use caution
        if (useCaution.isNotEmpty) ...[
          _buildCategoryHeader(
            icon: Icons.warning_rounded,
            title: context.tr('use_caution_title'),
            subtitle: context.tr('use_caution_sub'),
            color: AppColors.warningAmber,
            count: useCaution.length,
          ),
          const SizedBox(height: 8),
          ...useCaution.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGameCard(item: item),
              )),
          const SizedBox(height: 16),
        ],

        // Not recommended right now
        if (notRecommended.isNotEmpty) ...[
          _buildCategoryHeader(
            icon: Icons.block_rounded,
            title: context.tr('not_rec_title'),
            subtitle: context.tr('not_rec_sub'),
            color: AppColors.dangerRed,
            count: notRecommended.length,
          ),
          const SizedBox(height: 8),
          ...notRecommended.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGameCard(item: item),
              )),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int count,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          );
        }

        return Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameCard({
    required ({GameProfile game, GameActivity activity, RiskLevel risk}) item,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceHighlight =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: surfaceHighlight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GameIconWidget(
            iconName: item.game.iconName,
            size: 24,
            fallbackColor: item.game.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.game.name} · ${item.activity.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.activity.canPause && !item.activity.requiresCompletion
                      ? context.tr('can_pause_safely')
                      : '${TimeUtils.formatMinutes(item.activity.typicalDuration)} (${TimeUtils.formatMinutes(item.activity.minMinutes)}–${TimeUtils.formatMinutes(item.activity.maxMinutes)})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: item.risk.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              RiskCalculator.getRiskLabel(item.risk),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: item.risk.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameFilterTab({
    required String id,
    required String label,
    IconData? icon,
    String? iconName,
    int? fallbackColor,
    required int count,
    required bool isSelected,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final borderColor = isSelected
        ? primaryColor
        : (theme.dividerTheme.color ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)));

    final containerColor = isSelected
        ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
        : surfaceColor;

    final textColor = isSelected
        ? primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.9 : 0.85);

    final badgeBg = isSelected
        ? primaryColor.withValues(alpha: isDark ? 0.30 : 0.18)
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06));

    final badgeTextColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white70 : Colors.black87);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameFilter = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null)
              GameIconWidget(
                iconName: iconName,
                size: 13,
                fallbackColor: fallbackColor ?? primaryColor.toARGB32(),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 13,
                color: isSelected ? primaryColor : textColor.withValues(alpha: 0.7),
              ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
