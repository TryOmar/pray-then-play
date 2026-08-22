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
    final plannedDuration = _desiredSessionMinutes ??
        (nextPrayerTime != null
            ? (nextPrayerTime.difference(now).inMinutes - bufferMinutes)
                .clamp(1, 1440)
            : 60);
    final sessionEndTime =
        _desiredSessionMinutes == null && nextPrayerTime != null
            ? nextPrayerTime.subtract(Duration(minutes: bufferMinutes))
            : now.add(Duration(minutes: plannedDuration));

    final is24Hour = StorageService.is24HourFormat;
    final timeFormat = DateFormat(is24Hour ? 'HH:mm' : 'h:mm a');
    final userGames = ref.watch(userGamesProvider);

    // Retrieve today's prayer times
    final prayerTimes = ref.watch(dailyPrayerTimesProvider);
    final upcomingPrayersInSession = <MapEntry<String, DateTime>>[];

    if (prayerTimes != null) {
      for (final entry in prayerTimes.allPrayers) {
        if (entry.key.toLowerCase() == 'sunrise') continue;
        if (entry.value.isAfter(now) && entry.value.isBefore(sessionEndTime)) {
          upcomingPrayersInSession.add(entry);
        }
      }
    }

    final hasPrayerBreak = upcomingPrayersInSession.isNotEmpty;
    final isOverrunningNext = nextPrayerTime != null &&
        sessionEndTime.isAfter(
            nextPrayerTime.subtract(Duration(minutes: bufferMinutes)));

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

    if (upcomingPrayersInSession.isNotEmpty) {
      for (final prayer in upcomingPrayersInSession) {
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
        final breakEndTime =
            prayer.value.add(const Duration(minutes: prayerBreakMinutes));
        sessionSegments.add((
          type: 'prayer',
          duration: prayerBreakMinutes,
          startTime: prayer.value,
          endTime: breakEndTime,
          label: '$prayerLabel (15m)',
          color: AppColors.warningAmber,
          icon: Icons.mosque_rounded,
          prayerName: prayer.key,
        ));

        cursorTime = breakEndTime;
      }

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
    } else if (isOpenSession &&
        nextPrayerTime != null &&
        nextPrayerName.isNotEmpty) {
      sessionSegments.add((
        type: 'play',
        duration: plannedDuration,
        startTime: now,
        endTime: sessionEndTime,
        label: '${TimeUtils.formatMinutes(plannedDuration)} Play',
        color: AppColors.primaryCyan,
        icon: Icons.sports_esports_rounded,
        prayerName: null,
      ));

      const prayerBreakMinutes = 15;
      final prayerLabel = context.tr('prayer_${nextPrayerName.toLowerCase()}');
      sessionSegments.add((
        type: 'prayer',
        duration: prayerBreakMinutes,
        startTime: nextPrayerTime,
        endTime: nextPrayerTime.add(const Duration(minutes: prayerBreakMinutes)),
        label: '$prayerLabel (15m)',
        color: AppColors.warningAmber,
        icon: Icons.mosque_rounded,
        prayerName: nextPrayerName,
      ));
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
                        ? (nextPrayerName.isNotEmpty
                            ? 'Until ${context.tr('prayer_${nextPrayerName.toLowerCase()}')} (${TimeUtils.formatMinutes(plannedDuration)})'
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
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: sessionSegments.map((seg) {
                final pct = totalSegMinutes > 0
                    ? (seg.duration / totalSegMinutes * 100).round()
                    : 100;
                final flex = seg.type == 'prayer'
                    ? seg.duration.clamp(35, 99999)
                    : seg.duration.clamp(25, 99999);

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

          // 2. Synchronized Proportional Multi-Milestone Flow (Seamless Node-to-Node Connectors & 100% Contained Circles)
          Builder(
            builder: (context) {
              final segmentWidgets = <Widget>[];
              final prayerSegments = sessionSegments
                  .where((s) => s.type == 'prayer')
                  .toList();
              final playSegments = sessionSegments
                  .where((s) => s.type == 'play')
                  .toList();

              if (prayerSegments.isEmpty) {
                // Single uninterrupted play session (Now -> Session Ends)
                final playSeg = playSegments.isNotEmpty
                    ? playSegments.first
                    : null;
                final duration = playSeg?.duration ?? plannedDuration;

                segmentWidgets.addAll([
                  _buildMilestoneNode(
                    label: context.tr('timeline_now'),
                    time: timeFormat.format(now),
                    color: AppColors.primaryCyan,
                    icon: Icons.sports_esports_rounded,
                    alignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    maxWidth: 54.0,
                    onTap: () => _showSessionSummaryModal(
                      context: context,
                      startTime: now,
                      endTime: sessionEndTime,
                      plannedDuration: plannedDuration,
                      isOpenSession: isOpenSession,
                      gamingMinutes: totalGamingMinutes,
                      prayerCount: 0,
                      is24Hour: is24Hour,
                    ),
                  ),
                  Expanded(
                    child: _buildTimelineConnector(
                      color: AppColors.successGreen,
                      durationMinutes: duration,
                      customLabel: context.tr('timeline_resume'),
                      onTap: () => _showWindowInspectionModal(
                        context: context,
                        title:
                            '${timeFormat.format(now)} ➔ ${timeFormat.format(sessionEndTime)} Gaming Window',
                        durationMinutes: duration,
                        startTime: now,
                        endTime: sessionEndTime,
                        status: GamingStatus.safe,
                        userGames: userGames,
                        is24Hour: is24Hour,
                      ),
                    ),
                  ),
                  _buildMilestoneNode(
                    label: context.tr('timeline_session_end'),
                    time: timeFormat.format(sessionEndTime),
                    color: AppColors.successGreen,
                    icon: Icons.check_circle_rounded,
                    alignment: CrossAxisAlignment.end,
                    textAlign: TextAlign.end,
                    maxWidth: 58.0,
                    onTap: () => _showSessionSummaryModal(
                      context: context,
                      startTime: now,
                      endTime: sessionEndTime,
                      plannedDuration: plannedDuration,
                      isOpenSession: isOpenSession,
                      gamingMinutes: totalGamingMinutes,
                      prayerCount: 0,
                      is24Hour: is24Hour,
                    ),
                  ),
                ]);
              } else {
                // Multi-prayer session: Alternating [Now Node] -> [Play Connector 0] -> [Prayer Node 0] -> [Play Connector 1] ... -> [Session End Node]
                // 1. First Node: Now
                segmentWidgets.add(
                  _buildMilestoneNode(
                    label: context.tr('timeline_now'),
                    time: timeFormat.format(now),
                    color: AppColors.primaryCyan,
                    icon: Icons.sports_esports_rounded,
                    alignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    maxWidth: 54.0,
                    onTap: () => _showSessionSummaryModal(
                      context: context,
                      startTime: now,
                      endTime: sessionEndTime,
                      plannedDuration: plannedDuration,
                      isOpenSession: isOpenSession,
                      gamingMinutes: totalGamingMinutes,
                      prayerCount: upcomingPrayersInSession.length,
                      is24Hour: is24Hour,
                    ),
                  ),
                );

                // 2. Interleave: [Play Connector i] -> [Prayer Node i]
                for (int i = 0; i < prayerSegments.length; i++) {
                  final prayerSeg = prayerSegments[i];
                  final playBefore = (i < playSegments.length)
                      ? playSegments[i]
                      : null;
                  final playDuration = playBefore?.duration ?? 0;
                  final flex = playDuration.clamp(20, 99999);

                  // Connector between previous milestone and this prayer
                  segmentWidgets.add(
                    Expanded(
                      flex: flex,
                      child: _buildTimelineConnector(
                        color: AppColors.primaryCyan,
                        durationMinutes: playDuration,
                        customLabel: context.tr('timeline_resume'),
                        onTap: playBefore != null
                            ? () => _showWindowInspectionModal(
                                  context: context,
                                  title:
                                      '${timeFormat.format(playBefore.startTime)} ➔ ${timeFormat.format(playBefore.endTime)} Gaming Window',
                                  durationMinutes: playBefore.duration,
                                  startTime: playBefore.startTime,
                                  endTime: playBefore.endTime,
                                  status: GamingStatus.safe,
                                  userGames: userGames,
                                  is24Hour: is24Hour,
                                )
                            : null,
                      ),
                    ),
                  );

                  // Prayer Milestone Node
                  final prayerNameTranslated = prayerSeg.prayerName != null
                      ? context.tr('prayer_${prayerSeg.prayerName!.toLowerCase()}')
                      : 'Prayer';

                  segmentWidgets.add(
                    _buildMilestoneNode(
                      label: '$prayerNameTranslated Break',
                      time: timeFormat.format(prayerSeg.startTime),
                      sublabel: '${prayerSeg.duration}m break',
                      color: AppColors.warningAmber,
                      icon: Icons.mosque_rounded,
                      alignment: CrossAxisAlignment.center,
                      textAlign: TextAlign.center,
                      maxWidth: 64.0,
                      onTap: () => _showPrayerInfoModal(
                        context: context,
                        ref: ref,
                        name: prayerSeg.prayerName ?? 'Prayer',
                        time: prayerSeg.startTime,
                        breakMinutes: prayerSeg.duration,
                        is24Hour: is24Hour,
                      ),
                    ),
                  );
                }

                // 3. Final Play Connector after last prayer (if any play window left)
                final finalPlay = playSegments.length > prayerSegments.length
                    ? playSegments.last
                    : null;
                final finalPlayDuration = finalPlay?.duration ?? 0;
                final finalFlex = finalPlayDuration.clamp(20, 99999);

                segmentWidgets.add(
                  Expanded(
                    flex: finalFlex,
                    child: _buildTimelineConnector(
                      color: AppColors.primaryCyan,
                      durationMinutes: finalPlayDuration,
                      customLabel: context.tr('timeline_resume'),
                      onTap: finalPlay != null
                          ? () => _showWindowInspectionModal(
                                context: context,
                                title:
                                    '${timeFormat.format(finalPlay.startTime)} ➔ ${timeFormat.format(finalPlay.endTime)} Gaming Window',
                                durationMinutes: finalPlay.duration,
                                startTime: finalPlay.startTime,
                                endTime: finalPlay.endTime,
                                status: GamingStatus.safe,
                                userGames: userGames,
                                is24Hour: is24Hour,
                              )
                          : null,
                    ),
                  ),
                );

                // 4. Final Node: Session Ends
                segmentWidgets.add(
                  _buildMilestoneNode(
                    label: context.tr('timeline_session_end'),
                    time: timeFormat.format(sessionEndTime),
                    color: AppColors.primaryCyan,
                    icon: Icons.sports_esports_rounded,
                    alignment: CrossAxisAlignment.end,
                    textAlign: TextAlign.end,
                    maxWidth: 58.0,
                    onTap: () => _showSessionSummaryModal(
                      context: context,
                      startTime: now,
                      endTime: sessionEndTime,
                      plannedDuration: plannedDuration,
                      isOpenSession: isOpenSession,
                      gamingMinutes: totalGamingMinutes,
                      prayerCount: upcomingPrayersInSession.length,
                      is24Hour: is24Hour,
                    ),
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: segmentWidgets,
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
  }) {
    final nodeContent = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 11,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 9.5,
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
              style: const TextStyle(
                fontSize: 8.0,
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
                  fontSize: 7.0,
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

  Widget _buildTimelineConnector({
    required Color color,
    int? durationMinutes,
    String? customLabel,
    VoidCallback? onTap,
  }) {
    final connectorContent = Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          Widget? badge;

          if (durationMinutes != null && durationMinutes > 0 && w >= 18) {
            final formatted = TimeUtils.formatMinutes(durationMinutes);
            String text;
            if (w >= 75) {
              text = customLabel != null
                  ? '$formatted • $customLabel'
                  : formatted;
            } else {
              text = formatted;
            }

            badge = Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.0),
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
                  maxWidth: (w - 4).clamp(10.0, 9999.0),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (w >= 44) ...[
                        Icon(
                          Icons.sports_esports_rounded,
                          size: 9,
                          color: color,
                        ),
                        const SizedBox(width: 2.5),
                      ],
                      Text(
                        text,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 2.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              if (badge != null) badge,
            ],
          );
        },
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: connectorContent,
      );
    }
    return connectorContent;
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
                            '${context.tr('prayer_${name.toLowerCase()}')} Break',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${TimeUtils.formatTime(time, is24Hour: is24Hour)} – ${TimeUtils.formatTime(time.add(Duration(minutes: breakMinutes)), is24Hour: is24Hour)} ($breakMinutes min buffer)',
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
                  Container(
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
                Text(
                  'Pause your games, make wudhu, and perform ${context.tr('prayer_${name.toLowerCase()}')} on time.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
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
