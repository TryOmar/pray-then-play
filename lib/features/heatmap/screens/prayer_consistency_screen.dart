import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/prayer_record.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';

class PrayerConsistencyScreen extends ConsumerStatefulWidget {
  const PrayerConsistencyScreen({super.key});

  @override
  ConsumerState<PrayerConsistencyScreen> createState() =>
      _PrayerConsistencyScreenState();
}

class _PrayerConsistencyScreenState
    extends ConsumerState<PrayerConsistencyScreen> {
  int _viewTab = 0; // 0: GitHub Contribution Graph, 1: 5-Prayer Breakdown, 2: Gaming Decisions
  DailyPrayerRecord? _hoveredOrSelectedRecord;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerConsistencyProvider);
    final notifier = ref.read(prayerConsistencyProvider.notifier);

    final contributionWeeks = notifier.getContributionWeeks(18);
    final monthlySummary =
        notifier.getMonthlySummary(state.selectedYear, state.selectedMonth);
    final reflection = notifier.getHabitReflection();
    final achievements = notifier.getAllAchievements();
    final streak = notifier.getConsistencyStreak();

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Prayer Consistency',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: () => _showPhilosophyDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Top Overall Metric Hero
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _buildHeroConsistencyCard(
                context,
                monthlySummary: monthlySummary,
                streak: streak,
                protectedCount: state.protectedPrayers,
              ),
            ),
          ),

          // Section 1: Today's 5-Prayer Checklist
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildTodaySection(context, ref),
            ),
          ),

          // Starter Guide Banner for Fresh Installs
          if (!notifier.hasAnyRecordedPrayers)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildStarterGuideBanner(context, theme),
              ),
            ),

          // View Selector Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  _buildTabButton(context.tr('tab_contribution_heatmap'), 0),
                  const SizedBox(width: 8),
                  _buildTabButton(context.tr('tab_5prayer_matrix'), 1),
                  const SizedBox(width: 8),
                  _buildTabButton(context.tr('tab_gaming_decisions'), 2),
                ],
              ),
            ),
          ),

          // Main Interactive Visualization
          if (_viewTab == 0) ...[
            // GitHub-Style Standard Contribution Heatmap Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGitHubContributionCard(
                  context,
                  weeks: contributionWeeks,
                  isLight: isLight,
                ),
              ),
            ),
          ] else if (_viewTab == 1) ...[
            // 5-Prayer Breakdown Matrix
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFivePrayerDetailedMatrix(context, monthlySummary),
              ),
            ),
          ] else ...[
            // Gaming & Salah Reflection Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGamingReflectionSection(context, reflection, state),
              ),
            ),
          ],

          // Behavioral Insights Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildBehavioralInsightCard(context, reflection),
            ),
          ),

          // Habit & Discipline Achievements
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: _buildAchievementsSection(context, achievements),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _viewTab == index;
    final primary = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? primary
                  : Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? primary
                        : Theme.of(context).textTheme.bodySmall?.color ??
                            AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hero Consistency Card
  Widget _buildHeroConsistencyCard(
    BuildContext context, {
    required MonthlyPrayerSummary monthlySummary,
    required int streak,
    required int protectedCount,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('consistency_nav'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      context.trFormat('on_time_this_month_format', {'rate': monthlySummary.onTimeRate.toStringAsFixed(0)}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${monthlySummary.onTimeRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Metric Pills
          Row(
            children: [
              _buildMetricCapsule(
                context,
                title: context.tr('streak_stat'),
                value: context.trFormat('days_count', {'days': streak}),
                subtitle: context.tr('current_active'),
                color: AppColors.primaryCyan,
                icon: Icons.local_fire_department_rounded,
              ),
              const SizedBox(width: 8),
              _buildMetricCapsule(
                context,
                title: context.tr('protected_stat'),
                value: '$protectedCount',
                subtitle: context.tr('gaming_sessions_label'),
                color: AppColors.successGreen,
                icon: Icons.shield_rounded,
              ),
              const SizedBox(width: 8),
              _buildMetricCapsule(
                context,
                title: context.tr('late_stat'),
                value: '${monthlySummary.lateCount}',
                subtitle: context.tr('this_month_label'),
                color: monthlySummary.lateCount == 0
                    ? AppColors.textMuted
                    : AppColors.warningAmber,
                icon: Icons.access_time_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCapsule(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarterGuideBanner(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('starter_guide_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('starter_guide_body'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 1: Today's 5-Prayer Checklist
  Widget _buildTodaySection(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final record = ref
        .watch(prayerConsistencyProvider.notifier)
        .getRecord(today);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('today_salah_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.trFormat('prayers_recorded_count', {'count': record.completedCount}),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((name) {
              final status = record.prayers[name] ?? PrayerStatus.notRecorded;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showQuickRecordSheet(
                      context, ref, today, name, status),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: status.color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(status.icon, size: 17, color: status.color),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.tr('prayer_${name.toLowerCase()}'),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            status.getLocalizedLabel(context),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- THE CLASSIC GITHUB CONTRIBUTION GRAPH STRUCTURE ---
  Widget _buildGitHubContributionCard(
    BuildContext context, {
    required List<ContributionWeek> weeks,
    required bool isLight,
  }) {
    final theme = Theme.of(context);
    final selectedInfo = _hoveredOrSelectedRecord;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                  size: 18, color: AppColors.successGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Prayer Activity Heatmap',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Past ${weeks.length}w',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Each column represents a week. Tap any day square to view its 5-prayer breakdown.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          // Interactive Horizontal Scroll Container
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Auto scroll to newest week on the right
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Labels Header
                Row(
                  children: [
                    const SizedBox(width: 32), // offset for weekday labels
                    ...weeks.map((w) {
                      return SizedBox(
                        width: 17, // cell width (14) + gap (3)
                        child: Text(
                          w.monthLabel ?? '',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),

                // Heatmap Grid: 7 Rows (Mon - Sun)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekday Labels (Mon, Wed, Fri)
                    SizedBox(
                      width: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 17 * 0, child: Text(context.tr('weekday_mon'), style: const TextStyle(fontSize: 9, color: AppColors.textMuted))),
                          const SizedBox(height: 17 * 1, child: SizedBox()),
                          SizedBox(height: 17 * 0, child: Text(context.tr('weekday_wed'), style: const TextStyle(fontSize: 9, color: AppColors.textMuted))),
                          const SizedBox(height: 17 * 1, child: SizedBox()),
                          SizedBox(height: 17 * 0, child: Text(context.tr('weekday_fri'), style: const TextStyle(fontSize: 9, color: AppColors.textMuted))),
                          const SizedBox(height: 17 * 2, child: SizedBox()),
                        ],
                      ),
                    ),

                    // Columns of Weeks
                    Row(
                      children: weeks.map((week) {
                        return Column(
                          children: List.generate(7, (dayIndex) {
                            final record = (dayIndex < week.days.length) ? week.days[dayIndex] : null;
                            return _buildGitHubHeatmapCell(context, record, isLight);
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Bottom Bar: Selected Day Snippet + Multi-Color Semantic Legend
          if (selectedInfo != null) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getCellColor(isLight, selectedInfo),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getRecordTooltip(selectedInfo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Multi-Color Semantic Color Legend
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _buildSemanticLegendChip(
                isLight ? const Color(0xFF059669) : const Color(0xFF10B981),
                context.tr('legend_5_perfect'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFF0284C7) : const Color(0xFF06B6D4),
                context.tr('legend_4_ontime'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
                context.tr('legend_3_ontime'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                context.tr('legend_contains_late'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFF7C3AED) : const Color(0xFFA855F7),
                context.tr('legend_partial'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
                context.tr('status_missed'),
              ),
              _buildSemanticLegendChip(
                isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                context.tr('status_not_recorded'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubHeatmapCell(BuildContext context, DailyPrayerRecord? record, bool isLight) {
    if (record == null) {
      // Future or blank cell
      return Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    final color = _getCellColor(isLight, record);

    return GestureDetector(
      onTap: () {
        setState(() => _hoveredOrSelectedRecord = record);
        _showDayDetailSheet(context, record);
      },
      child: Tooltip(
        message: _getRecordTooltip(record),
        child: Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: record.onTimeCount >= 4
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  String _getRecordTooltip(DailyPrayerRecord record) {
    final dateStr = DateFormat('EEE, MMM d').format(record.date);
    if (record.completedCount == 0) {
      if (record.missedCount > 0) return '$dateStr: ${record.missedCount} missed prayer(s)';
      return '$dateStr: Not recorded yet';
    }
    if (record.onTimeCount == 5) return '$dateStr: 5/5 Perfect (All on time)';
    final parts = <String>[];
    if (record.onTimeCount > 0) parts.add('${record.onTimeCount} on time');
    if (record.lateCount > 0) parts.add('${record.lateCount} late');
    if (record.missedCount > 0) parts.add('${record.missedCount} missed');
    return '$dateStr: ${parts.join(', ')}';
  }

  Color _getCellColor(bool isLight, DailyPrayerRecord? record) {
    if (record == null || record.completedCount == 0) {
      if (record != null && record.missedCount > 0) {
        return isLight ? const Color(0xFFDC2626) : const Color(0xFFEF4444); // Crimson
      }
      // Not recorded
      return isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    }

    // If missed prayers exist
    if (record.missedCount > 0) {
      return isLight ? const Color(0xFFDC2626) : const Color(0xFFEF4444); // Red
    }

    // If late prayers exist
    if (record.lateCount >= 1 && record.onTimeCount < 5) {
      return isLight ? const Color(0xFFD97706) : const Color(0xFFF59E0B); // Solar Amber
    }

    // Pure On-Time Spectrum
    if (record.onTimeCount >= 5) {
      return isLight ? const Color(0xFF059669) : const Color(0xFF10B981); // Emerald Green
    } else if (record.onTimeCount == 4) {
      return isLight ? const Color(0xFF0284C7) : const Color(0xFF06B6D4); // Electric Cyan
    } else if (record.onTimeCount == 3) {
      return isLight ? const Color(0xFF2563EB) : const Color(0xFF3B82F6); // Royal Blue
    } else {
      // 1-2 on time (Partial day)
      return isLight ? const Color(0xFF7C3AED) : const Color(0xFFA855F7); // Amethyst Purple
    }
  }

  Widget _buildSemanticLegendChip(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // --- 5-PRAYER DETAILED MATRIX VIEW ---
  Widget _buildFivePrayerDetailedMatrix(
      BuildContext context, MonthlyPrayerSummary summary) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_week_rounded,
                  size: 18, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('five_prayer_grid_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                context.trFormat('on_time_count_format', {'count': summary.onTimeCount, 'total': summary.totalRecorded}),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table header
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(context.tr('date_header'),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(context.tr('prayer_fajr')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    Text(context.tr('prayer_dhuhr')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    Text(context.tr('prayer_asr')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    Text(context.tr('prayer_maghrib')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    Text(context.tr('prayer_isha')[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(context.tr('rate_header'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Daily rows
          ListView.separated(
            itemCount: summary.days.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final record = summary.days[index];
              final dateStr = DateFormat('MMM d').format(record.date);
              final isToday = record.date.day == DateTime.now().day &&
                  record.date.month == DateTime.now().month;

              return GestureDetector(
                onTap: () => _showDayDetailSheet(context, record),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.primaryColor.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w500,
                            color: isToday
                                ? theme.primaryColor
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                              .map((prayer) {
                            final status =
                                record.prayers[prayer] ?? PrayerStatus.notRecorded;
                            return Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: status.color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: status == PrayerStatus.onTime
                                    ? [
                                        BoxShadow(
                                          color: status.color
                                              .withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  status.icon,
                                  size: 13,
                                  color: status == PrayerStatus.notRecorded
                                      ? Colors.white54
                                      : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${record.completedCount}/5',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: record.completedCount >= 4
                                  ? AppColors.successGreen
                                  : (record.completedCount >= 2
                                      ? AppColors.warningAmber
                                      : AppColors.textMuted),
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
        ],
      ),
    );
  }

  // Gaming Decisions & Protected Prayers
  Widget _buildGamingReflectionSection(BuildContext context,
      GamingHabitReflection reflection, PrayerConsistencyState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_esports_rounded,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('gaming_salah_decisions_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('gaming_salah_decisions_sub'),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          _buildDecisionStatRow(
            context,
            count: state.avoidedRiskyQueue,
            label: context.tr('decision_avoided_risky'),
            icon: Icons.shield_rounded,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 10),
          _buildDecisionStatRow(
            context,
            count: state.stoppedToPray,
            label: context.tr('decision_stopped_to_pray'),
            icon: Icons.pause_circle_filled_rounded,
            color: AppColors.successGreen,
          ),
          const SizedBox(height: 10),
          _buildDecisionStatRow(
            context,
            count: state.choseShortGame,
            label: context.tr('decision_chose_short_game'),
            icon: Icons.timer_outlined,
            color: AppColors.warningAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionStatRow(
    BuildContext context, {
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Behavioral Insight Card
  Widget _buildBehavioralInsightCard(
      BuildContext context, GamingHabitReflection reflection) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('weekly_habit_reflection_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // What went well
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.trFormat('reflection_what_went_well', {
                    'prayer': reflection.mostConsistentPrayer == 'None yet'
                        ? context.tr('none_yet')
                        : context.tr('prayer_${reflection.mostConsistentPrayer.toLowerCase()}'),
                  }),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Opportunity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: AppColors.warningAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${context.tr('opportunity_label')}: ${(reflection.opportunityPrayer.isNotEmpty && reflection.opportunityPrayer != 'Build your baseline') ? context.tr('reflection_insight_short_games') : context.tr('reflection_insight_complete_prayers')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Redesigned Habit & Discipline Badges Section
  Widget _buildAchievementsSection(
      BuildContext context, List<HabitAchievement> achievements) {
    final theme = Theme.of(context);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Progress Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.military_tech_rounded,
                    size: 18, color: theme.primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('badges_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      context.trFormat('badges_unlocked_format', {'unlocked': unlockedCount, 'total': totalCount}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  context.trFormat('percent_done_format', {'percent': (progress * 100).toInt()}),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Linear Progress Track
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: theme.inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),

          // List of Clean Badge Cards
          ListView.separated(
            itemCount: achievements.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final badge = achievements[index];
              return _buildBadgeCard(context, badge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, HabitAchievement badge) {
    final theme = Theme.of(context);
    final isUnlocked = badge.isUnlocked;
    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (theme.inputDecorationTheme.fillColor ?? AppColors.surfaceElevated)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? primaryColor.withValues(alpha: 0.35)
              : (theme.dividerTheme.color ?? AppColors.surfaceHighlight),
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medallion Emblem Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.25),
                        primaryColor.withValues(alpha: 0.08),
                      ],
                    )
                  : null,
              color: isUnlocked
                  ? null
                  : theme.inputDecorationTheme.fillColor ??
                      AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isUnlocked
                    ? primaryColor.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                badge.icon,
                size: 20,
                color: isUnlocked ? primaryColor : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      context.tr('badge_${badge.id}_title'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? theme.colorScheme.onSurface
                            : AppColors.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (isUnlocked ? primaryColor : AppColors.textMuted)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.tr('badge_cat_${badge.category.toLowerCase().replaceAll(' ', '_')}').toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color:
                              isUnlocked ? primaryColor : AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr('badge_${badge.id}_desc'),
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked
                        ? (theme.textTheme.bodySmall?.color ??
                            AppColors.textMuted)
                        : AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Unlocked Pill or Lock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.successGreen.withValues(alpha: 0.14)
                  : theme.inputDecorationTheme.fillColor ??
                      AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUnlocked
                    ? AppColors.successGreen.withValues(alpha: 0.4)
                    : (theme.dividerTheme.color ?? AppColors.surfaceHighlight),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUnlocked
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  size: 12,
                  color:
                      isUnlocked ? AppColors.successGreen : AppColors.textMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  isUnlocked ? context.tr('unlocked') : context.tr('locked'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? AppColors.successGreen
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Day Detail Summary Bottom Sheet (When tapping a day square on the heatmap)
  void _showDayDetailSheet(BuildContext context, DailyPrayerRecord record) {
    final dateFormatted = DateFormat('EEEE, MMMM d').format(record.date);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final currentRecord = ref
              .watch(prayerConsistencyProvider.notifier)
              .getRecord(record.date);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentRecord.onTimeCount}/5 on time · ${currentRecord.consistencyRate.toStringAsFixed(0)}% consistency',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table of 5 Prayers with instant status changer
                ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((name) {
                  final status = currentRecord.prayers[name] ?? PrayerStatus.notRecorded;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(status.icon, size: 18, color: status.color),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('prayer_${name.toLowerCase()}'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),

                        // Status pill selector
                        DropdownButton<PrayerStatus>(
                          value: status,
                          underline: const SizedBox(),
                          dropdownColor: theme.colorScheme.surface,
                          items: PrayerStatus.values
                              .where((s) => s != PrayerStatus.upcoming)
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: s.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(s.getLocalizedLabel(context),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurface)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              ref
                                  .read(prayerConsistencyProvider.notifier)
                                  .updatePrayerStatus(
                                      record.date, name, newStatus);
                              setModalState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Unrecorded prayers are treated as not recorded, not missed.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Quick 1-tap sheet for recording today's prayers
  void _showQuickRecordSheet(BuildContext context, WidgetRef ref,
      DateTime date, String prayerName, PrayerStatus currentStatus) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                    color: theme.dividerTheme.color ?? AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.mosque_rounded, size: 20, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Did you pray $prayerName?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Choose timing to update your consistency history.',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildQuickActionButton(
                ctx,
                label: 'Yes, on time',
                color: AppColors.successGreen,
                icon: Icons.check_circle_rounded,
                onTap: () {
                  ref
                      .read(prayerConsistencyProvider.notifier)
                      .updatePrayerStatus(date, prayerName, PrayerStatus.onTime);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _buildQuickActionButton(
                ctx,
                label: 'Yes, late',
                color: AppColors.warningAmber,
                icon: Icons.access_time_rounded,
                onTap: () {
                  ref
                      .read(prayerConsistencyProvider.notifier)
                      .updatePrayerStatus(date, prayerName, PrayerStatus.late);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _buildQuickActionButton(
                ctx,
                label: 'Not recorded yet / Clear',
                color: const Color(0xFF64748B),
                icon: Icons.radio_button_unchecked_rounded,
                onTap: () {
                  ref.read(prayerConsistencyProvider.notifier).updatePrayerStatus(
                      date, prayerName, PrayerStatus.notRecorded);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showPhilosophyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(context.tr('philosophy_title'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SingleChildScrollView(
          child: Text(
            context.tr('philosophy_content'),
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('understood_btn')),
          ),
        ],
      ),
    );
  }
}
