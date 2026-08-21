import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/time_utils.dart';

class SessionPlannerScreen extends ConsumerStatefulWidget {
  const SessionPlannerScreen({super.key});

  @override
  ConsumerState<SessionPlannerScreen> createState() =>
      _SessionPlannerScreenState();
}

class _SessionPlannerScreenState extends ConsumerState<SessionPlannerScreen> {
  double _sessionHours = 2.0;

  List<_TimelineEntry> _buildTimeline(BuildContext context) {
    final lat = StorageService.latitude;
    final lng = StorageService.longitude;
    if (lat == null || lng == null) return [];

    final now = DateTime.now();
    final sessionEnd =
        now.add(Duration(minutes: (_sessionHours * 60).toInt()));

    final prayers = PrayerService.calculatePrayerTimes(
      latitude: lat,
      longitude: lng,
      date: now,
      method: StorageService.calculationMethod,
    );

    final entries = <_TimelineEntry>[];

    // Session start
    entries.add(_TimelineEntry(
      time: now,
      label: context.tr('gaming_session_starts'),
      type: _EntryType.gaming,
    ));

    // Add prayers that fall within the session
    for (final prayer in prayers.allPrayers) {
      if (prayer.value.isAfter(now) && prayer.value.isBefore(sessionEnd)) {
        final localizedPrayer = context.tr('prayer_${prayer.key.toLowerCase()}');
        entries.add(_TimelineEntry(
          time: prayer.value,
          label: '$localizedPrayer - ${context.tr('pray_action')}',
          type: _EntryType.prayer,
        ));
        // Resume gaming after prayer (15 min)
        final resume = prayer.value.add(const Duration(minutes: 15));
        if (resume.isBefore(sessionEnd)) {
          entries.add(_TimelineEntry(
            time: resume,
            label: context.tr('continue_gaming'),
            type: _EntryType.gaming,
          ));
        }
      }
    }

    // Session end
    entries.add(_TimelineEntry(
      time: sessionEnd,
      label: context.tr('session_ends'),
      type: _EntryType.end,
    ));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _buildTimeline(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(context.tr('session_planner_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration selector
            Container(
              padding: const EdgeInsets.all(18),
              decoration: GlassmorphicDecoration.card(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('how_long_play'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _sessionHours,
                          min: 0.5,
                          max: 6,
                          divisions: 11,
                          onChanged: (v) {
                            setState(() => _sessionHours = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          TimeUtils.formatMinutes(
                              (_sessionHours * 60).toInt()),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              context.tr('session_planner_title').toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Timeline
            Expanded(
              child: ListView.builder(
                itemCount: timeline.length,
                itemBuilder: (context, index) {
                  final entry = timeline[index];
                  final isLast = index == timeline.length - 1;


                  final color = entry.type == _EntryType.prayer
                      ? Theme.of(context).primaryColor
                      : entry.type == _EntryType.gaming
                          ? AppColors.successGreen
                          : (Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.textMuted);

                  final icon = entry.type == _EntryType.prayer
                      ? Icons.mosque_rounded
                      : entry.type == _EntryType.gaming
                          ? Icons.sports_esports_rounded
                          : Icons.flag_rounded;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline line
                        SizedBox(
                          width: 40,
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Icon(icon, size: 16, color: color),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    color: Theme.of(context)
                                            .dividerTheme
                                            .color ??
                                        AppColors.surfaceHighlight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TimeUtils.formatTime(entry.time),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EntryType { gaming, prayer, end }

class _TimelineEntry {
  final DateTime time;
  final String label;
  final _EntryType type;

  const _TimelineEntry({
    required this.time,
    required this.label,
    required this.type,
  });
}
