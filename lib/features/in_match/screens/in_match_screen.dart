import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/time_utils.dart';

class InMatchScreen extends ConsumerStatefulWidget {
  const InMatchScreen({super.key});

  @override
  ConsumerState<InMatchScreen> createState() => _InMatchScreenState();
}

class _InMatchScreenState extends ConsumerState<InMatchScreen> {
  Timer? _ticker;
  Duration _matchDuration = Duration.zero;
  DateTime? _matchStart;
  int _minutesUntilPrayer = 999;
  String _nextPrayerName = '';
  bool _prayerArrived = false;
  bool _matchEnded = false;

  @override
  void initState() {
    super.initState();
    _matchStart = DateTime.now();
    ref.read(inMatchProvider.notifier).startMatch();
    _updateTime();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _matchDuration = DateTime.now().difference(_matchStart!);
        });
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final lat = StorageService.latitude;
    final lng = StorageService.longitude;
    if (lat == null || lng == null) return;

    final next = PrayerService.getNextPrayer(
      latitude: lat,
      longitude: lng,
      method: StorageService.calculationMethod,
    );

    if (next != null) {
      final mins = next.value.difference(DateTime.now()).inMinutes;
      setState(() {
        _minutesUntilPrayer = mins;
        _nextPrayerName = next.key;
        _prayerArrived = mins <= 0;
      });
    }
  }

  void _endMatch() {
    setState(() => _matchEnded = true);
    ref.read(inMatchProvider.notifier).endMatch();
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_matchEnded) {
      return _buildPostMatch();
    }
    return _buildInMatch();
  }

  Widget _buildInMatch() {
    final statusColor = _prayerArrived
        ? AppColors.dangerRed
        : _minutesUntilPrayer <= 5
            ? AppColors.dangerRed
            : _minutesUntilPrayer <= 15
                ? AppColors.warningAmber
                : AppColors.primaryCyan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(inMatchProvider.notifier).endMatch();
                      context.pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          'IN MATCH',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Match timer
              Container(
                padding: const EdgeInsets.all(32),
                decoration: GlassmorphicDecoration.neonCard(
                  glowColor: statusColor,
                  glowIntensity: _prayerArrived ? 0.25 : 0.1,
                ),
                child: Column(
                  children: [
                    Icon(
                      _prayerArrived
                          ? Icons.mosque_rounded
                          : Icons.sports_esports_rounded,
                      size: 40,
                      color: statusColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      TimeUtils.formatCountdown(_matchDuration),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'match duration',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prayer status message
              Container(
                padding: const EdgeInsets.all(18),
                decoration: GlassmorphicDecoration.statusCard(
                  statusColor: statusColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.mosque_rounded, color: statusColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _prayerArrived
                                ? '$_nextPrayerName has begun'
                                : '$_nextPrayerName in $_minutesUntilPrayer min',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _prayerArrived
                                ? 'Finish safely, then pray as soon as possible.'
                                : "You're in a match. Focus on the game.",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // End match button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _endMatch,
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  label: const Text('Match Finished'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostMatch() {
    final isPrayerTime = _minutesUntilPrayer <= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Match complete
              Container(
                padding: const EdgeInsets.all(32),
                decoration: GlassmorphicDecoration.neonCard(
                  glowColor: isPrayerTime
                      ? AppColors.dangerRed
                      : AppColors.successGreen,
                  glowIntensity: 0.15,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 56,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Match Complete',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${TimeUtils.formatDuration(_matchDuration)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Prayer reminder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPrayerTime
                            ? AppColors.dangerRed.withValues(alpha: 0.1)
                            : AppColors.primaryCyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPrayerTime
                              ? AppColors.dangerRed.withValues(alpha: 0.3)
                              : AppColors.primaryCyan.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mosque_rounded,
                            color: isPrayerTime
                                ? AppColors.dangerRed
                                : AppColors.primaryCyan,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPrayerTime
                                ? '$_nextPrayerName is currently in progress.\nPray before starting another match.'
                                : '$_nextPrayerName is in $_minutesUntilPrayer minutes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isPrayerTime
                                  ? AppColors.dangerRed
                                  : AppColors.textSecondary,
                              fontWeight: isPrayerTime
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.mosque_rounded, size: 18),
                  label: const Text('Pray Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPrayerTime
                        ? AppColors.dangerRed
                        : AppColors.primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              if (!isPrayerTime && _minutesUntilPrayer > 10) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continue Gaming'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
