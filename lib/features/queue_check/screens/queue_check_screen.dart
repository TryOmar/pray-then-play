import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/game_profile.dart';
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
  GameMode? _selectedMode;
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
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) => _updateTime());
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
      if (_selectedGame != null && _selectedMode != null) {
        _calculate();
      }
    }
  }

  void _calculate() {
    if (_selectedGame == null || _selectedMode == null) return;

    final userGames = ref.read(activeSelectedGamesProvider);
    final bufferMinutes = ref.read(safetyBufferMinutesProvider);

    setState(() {
      _result = RiskCalculator.checkQueue(
        game: _selectedGame!,
        mode: _selectedMode!,
        minutesUntilPrayer: _minutesUntilPrayer,
        nextPrayerName: _nextPrayerName,
        userGames: userGames,
        bufferMinutes: bufferMinutes,
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
      if (_selectedGame!.enabledModes.isNotEmpty) {
        _selectedMode = _selectedGame!.enabledModes.first;
        _calculate();
      }
    }

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceHighlight = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

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
                    const Text(
                      'Can I Queue?',
                      style: TextStyle(
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
                        Text(
                          '$_nextPrayerName in $_minutesUntilPrayer min  •  ${bufferMinutes}m buffer',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
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
                    const Text(
                      'YOUR GAMES',
                      style: TextStyle(
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
                        decoration: GlassmorphicDecoration.card(context: context),
                        child: const Text(
                          'No games configured yet. Go to Settings or Onboarding to select games.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: userGames.map((game) {
                          final isSelected = _selectedGame?.id == game.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGame = game;
                                _selectedMode = game.enabledModes.isNotEmpty
                                    ? game.enabledModes.first
                                    : null;
                              });
                              _calculate();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(game.color).withValues(alpha: 0.18)
                                    : surfaceColor,
                                borderRadius: BorderRadius.circular(10),
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
                                    size: 20,
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
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Mode Selection
            if (_selectedGame != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SELECT MATCH MODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...(_selectedGame!.enabledModes.map((mode) {
                        final isSelected = _selectedMode?.name == mode.name;
                        final risk = RiskCalculator.calculateRisk(
                          mode,
                          _minutesUntilPrayer,
                          bufferMinutes: bufferMinutes,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedMode = mode);
                              _calculate();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? risk.color.withValues(alpha: 0.1)
                                    : surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? risk.color
                                      : surfaceHighlight,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mode.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          mode.commitmentType == GameCommitmentType.flexible
                                              ? 'Flexible · Can leave anytime'
                                              : '~${mode.estimatedMinutes} min (${mode.minMinutes}–${mode.maxMinutes}m)',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: risk.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      RiskCalculator.getRiskLabel(risk),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: risk.color,
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

            // Result Card
            if (_result != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: _buildResult(bufferMinutes),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(int bufferMinutes) {
    final result = _result!;
    final color = result.riskLevel.color;

    final icon = result.riskLevel == RiskLevel.low
        ? Icons.check_circle_rounded
        : result.riskLevel == RiskLevel.medium
            ? Icons.warning_rounded
            : Icons.block_rounded;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowIntensity = result.riskLevel == RiskLevel.high
            ? 0.18 + (_pulseController.value * 0.12)
            : 0.1;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: GlassmorphicDecoration.neonCard(
            context: context,
            glowColor: color,
            glowIntensity: glowIntensity,
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 10),
              Text(
                RiskCalculator.getRiskLabel(result.riskLevel),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.recommendation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),

              const SizedBox(height: 20),
              _TimeComparisonBar(
                matchDuration: result.estimatedMatchDuration,
                minutesUntilPrayer: result.minutesUntilPrayer,
                bufferMinutes: bufferMinutes,
                color: color,
              ),

              const SizedBox(height: 20),

              // Action buttons & Alternatives
              if (result.riskLevel == RiskLevel.high) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(prayerConsistencyProvider.notifier)
                          .logGamingDecision(GamingDecisionType.avoidedRiskyQueue);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prayer Protected! Chose Salah before match queue.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.go('/consistency');
                    },
                    icon: const Icon(Icons.mosque_rounded, size: 18),
                    label: const Text('Pray First'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
                if (result.suggestedAlternatives.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'SAFE ALTERNATIVES FROM YOUR GAMES',
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
                            color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
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
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sports_esports_rounded, size: 18),
                    label: const Text('You Can Queue'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
    final maxVal = (matchDuration > minutesUntilPrayer ? matchDuration : minutesUntilPrayer).toDouble();
    final matchWidth = maxVal > 0 ? (matchDuration / maxVal) : 0.0;
    final prayerWidth = maxVal > 0 ? (minutesUntilPrayer / maxVal) : 0.0;

    return Column(
      children: [
        // Match Duration
        Row(
          children: [
            const SizedBox(
              width: 70,
              child: Text(
                'Match',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
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
              width: 50,
              child: Text(
                ' ${matchDuration}m',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Available Prayer Time
        Row(
          children: [
            const SizedBox(
              width: 70,
              child: Text(
                'Until Salah',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
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
              width: 50,
              child: Text(
                ' ${minutesUntilPrayer}m',
                textAlign: TextAlign.right,
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
