import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/risk_calculator.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/game_icon_widget.dart';

class RecommendedGamesWidget extends ConsumerWidget {
  final int minutesUntilPrayer;

  const RecommendedGamesWidget({
    super.key,
    required this.minutesUntilPrayer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGames = ref.watch(activeSelectedGamesProvider);
    final bufferMinutes = ref.watch(safetyBufferMinutesProvider);

    final recommendedNow = <_ModeItem>[];
    final useCaution = <_ModeItem>[];
    final notRecommended = <_ModeItem>[];

    for (final game in userGames) {
      for (final mode in game.enabledModes) {
        final risk = RiskCalculator.calculateRisk(
          mode,
          minutesUntilPrayer,
          bufferMinutes: bufferMinutes,
        );

        final item = _ModeItem(game: game, mode: mode, risk: risk);

        if (risk == RiskLevel.low) {
          recommendedNow.add(item);
        } else if (risk == RiskLevel.medium) {
          useCaution.add(item);
        } else {
          notRecommended.add(item);
        }
      }
    }

    if (userGames.isEmpty) {
      final textMuted =
          Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: GlassmorphicDecoration.card(context: context),
        child: Column(
          children: [
            Icon(Icons.sports_esports_outlined, size: 36, color: textMuted),
            const SizedBox(height: 10),
            Text(
              context.tr('no_games_selected_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('no_games_selected_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended now
        if (recommendedNow.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.check_circle_rounded,
            title: context.tr('rec_now_title'),
            subtitle: context.tr('rec_now_sub'),
            color: AppColors.successGreen,
          ),
          const SizedBox(height: 8),
          ...recommendedNow.take(5).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _GameModeCard(item: item),
              )),
          const SizedBox(height: 16),
        ],

        // Use caution
        if (useCaution.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.warning_rounded,
            title: context.tr('use_caution_title'),
            subtitle: context.tr('use_caution_sub'),
            color: AppColors.warningAmber,
          ),
          const SizedBox(height: 8),
          ...useCaution.take(4).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _GameModeCard(item: item),
              )),
          const SizedBox(height: 16),
        ],

        // Not recommended right now
        if (notRecommended.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.block_rounded,
            title: context.tr('not_rec_title'),
            subtitle: context.tr('not_rec_sub'),
            color: AppColors.dangerRed,
          ),
          const SizedBox(height: 8),
          ...notRecommended.take(4).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _GameModeCard(item: item),
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color ??
                AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final _ModeItem item;

  const _GameModeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFlexible = item.mode.commitmentType == GameCommitmentType.flexible;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.risk.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GameIconWidget(
            iconName: item.game.iconName,
            size: 32,
            fallbackColor: item.game.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.game.name} · ${item.mode.name}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  isFlexible
                      ? context.tr('can_pause_safely')
                      : '${TimeUtils.formatMinutes(item.mode.estimatedMinutes)} (${TimeUtils.formatMinutes(item.mode.minMinutes)}–${TimeUtils.formatMinutes(item.mode.maxMinutes)})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.risk.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isFlexible ? context.tr('pauseable_badge') : TimeUtils.formatMinutes(item.mode.estimatedMinutes),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.risk.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeItem {
  final GameProfile game;
  final GameMode mode;
  final RiskLevel risk;

  const _ModeItem({
    required this.game,
    required this.mode,
    required this.risk,
  });
}
