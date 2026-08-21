import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/models/game_session_record.dart';
import '../../../core/models/gaming_window.dart';
import '../../../core/models/prayer_record.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/risk_calculator.dart';
import '../../../core/widgets/game_icon_widget.dart';

class QueueCheckScreen extends ConsumerStatefulWidget {
  const QueueCheckScreen({super.key});

  @override
  ConsumerState<QueueCheckScreen> createState() => _QueueCheckScreenState();
}

class _QueueCheckScreenState extends ConsumerState<QueueCheckScreen>
    with SingleTickerProviderStateMixin {
  GameProfile? _selectedGame;
  GameActivity? _selectedActivity;
  int? _desiredSessionMinutes; // null = use activity typical duration
  QueueCheckResult? _result;
  Timer? _ticker;
  int _minutesUntilPrayer = 999;
  String _nextPrayerName = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _updateTime();
    _ticker =
        Timer.periodic(const Duration(seconds: 15), (_) => _updateTime());
  }

  void _updateTime() {
    final lat = StorageService.latitude;
    final lng = StorageService.longitude;
    if (lat == null || lng == null) return;

    final next = PrayerService.getNextPrayer(
      latitude: lat,
      longitude: lng,
      method: StorageService.calculationMethod,
      asrMethod: StorageService.asrMethod,
    );

    if (next != null && mounted) {
      setState(() {
        _minutesUntilPrayer = next.value.difference(DateTime.now()).inMinutes;
        _nextPrayerName = next.key;
      });
      if (_selectedGame != null && _selectedActivity != null) {
        _calculate();
      }
    }
  }

  void _calculate() {
    if (_selectedGame == null || _selectedActivity == null) return;

    final userGames = ref.read(activeSelectedGamesProvider);
    final bufferMinutes = ref.read(safetyBufferMinutesProvider);

    setState(() {
      _result = RiskCalculator.checkQueue(
        game: _selectedGame!,
        activity: _selectedActivity!,
        minutesUntilPrayer: _minutesUntilPrayer,
        nextPrayerName: _nextPrayerName.isEmpty ? 'Salah' : _nextPrayerName,
        userGames: userGames,
        bufferMinutes: bufferMinutes,
        desiredSessionMinutes: _desiredSessionMinutes,
      );
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userGames = ref.watch(activeSelectedGamesProvider);
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);

    // Auto-select first game if none selected
    if (_selectedGame == null && userGames.isNotEmpty) {
      _selectedGame = userGames.first;
      if (_selectedGame!.enabledActivities.isNotEmpty) {
        _selectedActivity = _selectedGame!.enabledActivities.first;
        _calculate();
      }
    } else if (_selectedGame != null) {
      // Keep game state fresh in case activities changed
      final match =
          userGames.where((g) => g.id == _selectedGame!.id).firstOrNull;
      if (match != null) {
        _selectedGame = match;
        if (_selectedActivity != null &&
            !match.activities.any((a) => a.id == _selectedActivity!.id)) {
          _selectedActivity = match.enabledActivities.isNotEmpty
              ? match.enabledActivities.first
              : null;
          _calculate();
        }
      }
    }

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceHighlight =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('nav_queue'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${_nextPrayerName.isNotEmpty ? context.tr('prayer_${_nextPrayerName.toLowerCase()}') : context.tr('next_prayer')} ${context.tr('in_time')} $_minutesUntilPrayer ${context.tr('min')}  •  $bufferMinutes ${context.tr('min')} ${context.tr('safety_buffer')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Game Selection (User's Games Only)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('select_game').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (userGames.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration:
                            GlassmorphicDecoration.card(context: context),
                        child: Text(
                          context.tr('no_games_selected_sub'),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: userGames.map((game) {
                            final isSelected = _selectedGame?.id == game.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGame = game;
                                    _selectedActivity =
                                        game.enabledActivities.isNotEmpty
                                            ? game.enabledActivities.first
                                            : null;
                                  });
                                  _calculate();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(game.color)
                                            .withValues(alpha: 0.18)
                                        : surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(game.color)
                                          : surfaceHighlight,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GameIconWidget(
                                        iconName: game.iconName,
                                        size: 22,
                                        fallbackColor: game.color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        game.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Color(game.color)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Activity Selection ("What are you planning to play?")
            if (_selectedGame != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('what_planning_play'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showAddActivityQuickDialog(
                                context, _selectedGame!),
                            child: Text(
                              context.tr('add_activity_btn'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_selectedGame!.enabledActivities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration:
                              GlassmorphicDecoration.card(context: context),
                          child: Text(
                            context.tr('no_activities_for_game'),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        )
                      else
                        ...(_selectedGame!.enabledActivities.map((activity) {
                          final isSelected =
                              _selectedActivity?.id == activity.id;
                          final risk = RiskCalculator.calculateRisk(
                            activity,
                            _minutesUntilPrayer,
                            bufferMinutes: bufferMinutes,
                            desiredSessionMinutes: _desiredSessionMinutes,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedActivity = activity);
                                _calculate();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? risk.color.withValues(alpha: 0.12)
                                      : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? risk.color
                                        : surfaceHighlight,
                                    width: isSelected ? 1.6 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 6,
                                            runSpacing: 2,
                                            children: [
                                              Text(
                                                activity.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (activity.isCustom)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    context.tr('custom_badge'),
                                                    style: TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 4,
                                            runSpacing: 2,
                                            children: [
                                              if (activity.canPause &&
                                                  !activity
                                                      .requiresCompletion) ...[
                                                const Icon(
                                                    Icons.pause_circle_outline,
                                                    size: 13,
                                                    color:
                                                        AppColors.successGreen),
                                                const SizedBox(width: 2),
                                                Text(
                                                  context.tr('pauseable_badge'),
                                                  style: const TextStyle(
                                                      color: AppColors
                                                          .successGreen,
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                              Text(
                                                '${activity.typicalDuration} ${context.tr('min')} (${activity.minMinutes}–${activity.maxMinutes} ${context.tr('min')})',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            risk.color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 80),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            RiskCalculator.getRiskLabel(risk),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: risk.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                    ],
                  ),
                ),
              ),

            // Session Duration Selector ("How long do you want to play?")
            if (_selectedActivity != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('how_long_play'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildDurationChip(
                              label: context.trFormat('duration_typical', {'duration': _selectedActivity!.typicalDuration}),
                              isSelected: _desiredSessionMinutes == null,
                              onTap: () {
                                setState(() => _desiredSessionMinutes = null);
                                _calculate();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildDurationChip(
                              label: '15 ${context.tr('min')}',
                              isSelected: _desiredSessionMinutes == 15,
                              onTap: () {
                                setState(() => _desiredSessionMinutes = 15);
                                _calculate();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildDurationChip(
                              label: '30 ${context.tr('min')}',
                              isSelected: _desiredSessionMinutes == 30,
                              onTap: () {
                                setState(() => _desiredSessionMinutes = 30);
                                _calculate();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildDurationChip(
                              label: '45 ${context.tr('min')}',
                              isSelected: _desiredSessionMinutes == 45,
                              onTap: () {
                                setState(() => _desiredSessionMinutes = 45);
                                _calculate();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildDurationChip(
                              label: '60 ${context.tr('min')}',
                              isSelected: _desiredSessionMinutes == 60,
                              onTap: () {
                                setState(() => _desiredSessionMinutes = 60);
                                _calculate();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildDurationChip(
                              label: _desiredSessionMinutes != null &&
                                      ![15, 30, 45, 60]
                                          .contains(_desiredSessionMinutes)
                                  ? context.trFormat('duration_custom_active', {'duration': _desiredSessionMinutes})
                                  : context.tr('duration_custom'),
                              isSelected: _desiredSessionMinutes != null &&
                                  ![15, 30, 45, 60]
                                      .contains(_desiredSessionMinutes),
                              onTap: () => _showCustomDurationDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Live Verdict Card
            if (_result != null && _selectedActivity != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: _buildVerdictCard(bufferMinutes),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceHighlight =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.18)
              : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : surfaceHighlight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).primaryColor
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildVerdictCard(int bufferMinutes) {
    final result = _result!;
    final color = result.riskLevel.color;
    final effectiveBuffer = _selectedActivity?.safetyBuffer ?? bufferMinutes;
    final plannedDuration =
        _desiredSessionMinutes ?? _selectedActivity!.typicalDuration;

    final String localizedVerdictTitle;
    final String localizedMessage;
    final String localizedRecommendation;
    final localizedPrayer = _nextPrayerName.isNotEmpty
        ? context.tr('prayer_${_nextPrayerName.toLowerCase()}')
        : context.tr('next_prayer');

    if (_selectedActivity!.canPause && !_selectedActivity!.requiresCompletion) {
      if (_minutesUntilPrayer <= effectiveBuffer) {
        localizedVerdictTitle = context.tr('verdict_prayer_imminent');
        localizedMessage = context.trFormat('msg_prayer_imminent', {
          'prayer': localizedPrayer,
          'mins': _minutesUntilPrayer,
          'buffer': effectiveBuffer,
        });
        localizedRecommendation = context.trFormat('rec_prayer_imminent', {
          'game': _selectedGame!.name,
          'activity': _selectedActivity!.name,
        });
      } else {
        localizedVerdictTitle = context.tr('verdict_pauseable_session');
        localizedMessage = context.trFormat('msg_pauseable_safe', {
          'game': _selectedGame!.name,
          'activity': _selectedActivity!.name,
        });
        localizedRecommendation = context.trFormat('rec_pauseable_safe', {
          'prayer': localizedPrayer,
          'mins': _minutesUntilPrayer,
          'safe': result.availableSafeMinutes,
        });
      }
    } else {
      if (result.riskLevel == RiskLevel.low) {
        localizedVerdictTitle = context.tr('verdict_safe_start');
        localizedMessage = context.trFormat('msg_safe_start', {
          'duration': plannedDuration,
          'safe': result.availableSafeMinutes,
          'buffer': effectiveBuffer,
        });
        localizedRecommendation = context.trFormat('rec_safe_start', {
          'prayer': localizedPrayer,
          'mins': _minutesUntilPrayer,
        });
      } else if (result.riskLevel == RiskLevel.medium) {
        localizedVerdictTitle = context.tr('verdict_overtime_risk');
        localizedMessage = context.trFormat('msg_overtime_risk', {
          'duration': _selectedActivity!.typicalDuration,
          'max': _selectedActivity!.maxMinutes,
          'buffer': effectiveBuffer,
        });
        localizedRecommendation = context.tr('rec_overtime_risk');
      } else {
        localizedVerdictTitle = context.tr('verdict_not_recommended');
        localizedMessage = context.trFormat('msg_not_rec', {
          'duration': _selectedActivity!.typicalDuration,
          'safe': result.availableSafeMinutes,
        });
        localizedRecommendation = context.trFormat('rec_not_rec', {
          'prayer': localizedPrayer,
        });
      }
    }

    // Fetch personal history statistics for this activity
    final stats = StorageService.getActivitySessionStats(
      _selectedGame!.id,
      _selectedActivity!.id,
    );

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowIntensity = result.riskLevel == RiskLevel.high
            ? 0.16 + (_pulseController.value * 0.12)
            : 0.08;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: GlassmorphicDecoration.neonCard(
            context: context,
            glowColor: color,
            glowIntensity: glowIntensity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verdict Badge Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color, width: 1.2),
                      ),
                      child: Text(
                        localizedVerdictTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizedMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizedRecommendation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.surfaceHighlight),
              const SizedBox(height: 16),

              // Breakdown Data Rows
              _buildBreakdownRow(
                icon: Icons.mosque_rounded,
                title: context.tr('next_salah_label'),
                value:
                    '${_nextPrayerName.isNotEmpty ? context.tr('prayer_${_nextPrayerName.toLowerCase()}') : context.tr('next_prayer')} ${context.tr('in_time')} $_minutesUntilPrayer ${context.tr('min')}',
                valueColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              _buildBreakdownRow(
                icon: Icons.shield_rounded,
                title: context.tr('safe_available_window'),
                value:
                    '${result.availableSafeMinutes} ${context.tr('min')} (${context.trFormat('in_prayer_buffer_sub', {'buffer': effectiveBuffer})})',
                valueColor: AppColors.successGreen,
              ),
              const SizedBox(height: 10),
              _buildBreakdownRow(
                icon: Icons.timer_rounded,
                title: context.tr('planned_session_label'),
                value:
                    '${_selectedActivity!.name} ($plannedDuration ${context.tr('min')})',
                valueColor: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 10),
              _buildBreakdownRow(
                icon: _selectedActivity!.canPause
                    ? Icons.check_circle_outline_rounded
                    : Icons.lock_clock_rounded,
                title: context.tr('pauseability_label'),
                value: _selectedActivity!.canPause
                    ? context.tr('can_pause_safely')
                    : context.tr('cannot_pause_safely'),
                valueColor: _selectedActivity!.canPause
                    ? AppColors.successGreen
                    : AppColors.warningAmber,
              ),

              // Personal Stats Box if history exists
              if (stats.sessionCount > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_rounded,
                          size: 18, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERSONAL SESSION HISTORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Global estimate: ${_selectedActivity!.minMinutes}–${_selectedActivity!.maxMinutes}m  •  Your average: ~${stats.averageDurationMinutes}m (${stats.sessionCount} sessions logged)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Time Comparison Bar
              _TimeComparisonBar(
                matchDuration: plannedDuration,
                minutesUntilPrayer: result.minutesUntilPrayer,
                bufferMinutes: effectiveBuffer,
                color: color,
              ),

              const SizedBox(height: 22),

              // Action buttons & Alternatives
              if (result.riskLevel == RiskLevel.high) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(prayerConsistencyProvider.notifier)
                          .logGamingDecision(
                              GamingDecisionType.avoidedRiskyQueue);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Prayer Protected! Chose Salah before match queue.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.go('/consistency');
                    },
                    icon: const Icon(Icons.mosque_rounded, size: 18),
                    label: Text(context.tr('pray_first_btn')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: color.computeLuminance() > 0.55
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
                if (result.suggestedAlternatives.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'SAFE ALTERNATIVES FROM YOUR LIBRARY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.suggestedAlternatives.take(3).map((alt) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor ??
                                AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: AppColors.successGreen),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  alt,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startSessionTracker(
                            context, _selectedGame!, _selectedActivity!, plannedDuration),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(context.tr('start_track_session_btn')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: color.computeLuminance() > 0.55
                              ? Colors.black
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomDurationDialog(BuildContext context) {
    int minutes = _desiredSessionMinutes ?? _selectedActivity!.typicalDuration;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(context.tr('set_session_duration_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes minutes',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: minutes.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: '$minutes min',
                onChanged: (val) =>
                    setDialogState(() => minutes = val.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel_btn')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _desiredSessionMinutes = minutes);
                _calculate();
                Navigator.pop(ctx);
              },
              child: Text(context.tr('set_duration_btn')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActivityQuickDialog(BuildContext context, GameProfile game) {
    final nameCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '30');
    bool canPause = false;
    bool isCompetitive = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${context.tr('add_activity_quick_title')} (${game.name})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('activity_name_hint'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('duration_selector_title'),
                  suffixText: context.tr('min'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('can_pause_safely')),
                value: canPause,
                onChanged: (val) => setModalState(() => canPause = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('cannot_pause_safely')),
                value: isCompetitive,
                onChanged: (val) => setModalState(() => isCompetitive = val),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final dur = int.tryParse(durCtrl.text.trim()) ?? 30;
                    final newAct = GameActivity(
                      id: '${game.id}_${DateTime.now().millisecondsSinceEpoch}',
                      gameId: game.id,
                      name: name,
                      typicalDuration: dur,
                      minMinutes: dur > 10 ? dur - 5 : dur,
                      maxMinutes: dur > 10 ? dur + 10 : dur + 5,
                      canPause: canPause,
                      requiresCompletion: !canPause,
                      isCompetitive: isCompetitive,
                      isCustom: true,
                    );
                    ref
                        .read(userGamesProvider.notifier)
                        .addCustomActivity(game.id, newAct);
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedActivity = newAct;
                    });
                    _calculate();
                  },
                  child: Text(context.tr('save_btn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSessionTracker(
    BuildContext context,
    GameProfile game,
    GameActivity activity,
    int plannedDuration,
  ) {
    final startTime = DateTime.now();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            GameIconWidget(
                iconName: game.iconName, size: 24, fallbackColor: game.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${game.name} · ${activity.name}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Session in progress! Have fun and remember your prayer reminder.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Text(
              'Planned: $plannedDuration min',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryCyan),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('keep_playing_btn')),
          ),
          ElevatedButton(
            onPressed: () async {
              final endTime = DateTime.now();
              final duration =
                  endTime.difference(startTime).inMinutes.clamp(1, 999);
              final record = GameSessionRecord(
                id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
                gameId: game.id,
                gameName: game.name,
                activityId: activity.id,
                activityName: activity.name,
                startedAt: startTime,
                endedAt: endTime,
                durationMinutes: duration,
              );
              await ref
                  .read(gameSessionHistoryProvider.notifier)
                  .logSession(record);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Session logged ($duration min)! Personal history updated.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                setState(() {});
              }
            },
            child: Text(context.tr('finish_session_btn')),
          ),
        ],
      ),
    );
  }
}

class _TimeComparisonBar extends StatelessWidget {
  final int matchDuration;
  final int minutesUntilPrayer;
  final int bufferMinutes;
  final Color color;

  const _TimeComparisonBar({
    required this.matchDuration,
    required this.minutesUntilPrayer,
    required this.bufferMinutes,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = (matchDuration > minutesUntilPrayer
            ? matchDuration
            : minutesUntilPrayer)
        .toDouble();
    final matchWidth = maxVal > 0 ? (matchDuration / maxVal) : 0.0;
    final prayerWidth = maxVal > 0 ? (minutesUntilPrayer / maxVal) : 0.0;

    return Column(
      children: [
        // Match Duration
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                context.tr('planned_session_label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: matchWidth.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                '$matchDuration ${context.tr('min')}',
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Available Prayer Time
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                context.tr('next_salah_label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: prayerWidth.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                '$minutesUntilPrayer ${context.tr('min')}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
