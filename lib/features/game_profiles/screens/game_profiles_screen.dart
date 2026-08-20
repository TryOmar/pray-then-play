import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/constants/game_data.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/widgets/game_icon_widget.dart';

class GameProfilesScreen extends ConsumerWidget {
  const GameProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGames = ref.watch(userGamesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Games & Modes',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Only enabled modes are used in recommendations',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAddGameDialog(context, ref),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_rounded, color: Theme.of(context).primaryColor, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = userGames[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GameCard(game: game),
                    );
                  },
                  childCount: userGames.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGameDialog(BuildContext context, WidgetRef ref) {
    int activeTab = 0; // 0: Browse Catalog, 1: Custom Game
    String searchQuery = '';
    final nameController = TextEditingController();
    final modeControllers = <_ModeController>[
      _ModeController(
        name: TextEditingController(text: 'Competitive'),
        duration: TextEditingController(text: '30'),
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final userGames = ref.watch(userGamesProvider);
          final catalog = GameData.defaultCatalog.where((g) {
            if (searchQuery.trim().isEmpty) return true;
            return g.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                g.category.label.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.82,
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Add Games to Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Mode Tabs
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 0
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                                : Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeTab == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Predefined Catalog (${GameData.defaultCatalog.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: activeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                color: activeTab == 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == 1
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                                : Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeTab == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Custom Game',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: activeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                color: activeTab == 1
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (activeTab == 0) ...[
                  // Catalog Search bar
                  TextField(
                    onChanged: (v) => setModalState(() => searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search catalog (e.g. Valorant, FIFA, Apex...)',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () => setModalState(() => searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Catalog list
                  Expanded(
                    child: ListView.separated(
                      itemCount: catalog.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final game = catalog[index];
                        final isAlreadyAdded = userGames.any((g) => g.id == game.id && g.isSelected);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAlreadyAdded
                                  ? AppColors.successGreen.withValues(alpha: 0.3)
                                  : (Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight),
                            ),
                          ),
                          child: Row(
                            children: [
                              GameIconWidget(iconName: game.iconName, size: 36, fallbackColor: game.color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${game.modes.length} modes • ${game.category.label}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(userGamesProvider.notifier).addCatalogGame(game);
                                  setModalState(() {});
                                },
                                icon: Icon(
                                  isAlreadyAdded ? Icons.check_rounded : Icons.add_rounded,
                                  size: 16,
                                ),
                                label: Text(isAlreadyAdded ? 'Added' : 'Add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyAdded
                                      ? AppColors.successGreen.withValues(alpha: 0.15)
                                      : Theme.of(context).primaryColor,
                                  foregroundColor: isAlreadyAdded
                                      ? AppColors.successGreen
                                      : Theme.of(context).scaffoldBackgroundColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Custom Game Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(hintText: 'Game name (e.g. Marvel Rivals)'),
                          ),
                          const SizedBox(height: 16),
                          const Text('MODES & DURATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          ...modeControllers.asMap().entries.map((entry) {
                            final i = entry.key;
                            final mc = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: mc.name,
                                      decoration: const InputDecoration(hintText: 'Mode name'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: mc.duration,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(hintText: 'min'),
                                    ),
                                  ),
                                  if (i > 0)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.dangerRed),
                                      onPressed: () => setModalState(() => modeControllers.removeAt(i)),
                                    ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                modeControllers.add(_ModeController(
                                  name: TextEditingController(),
                                  duration: TextEditingController(text: '20'),
                                ));
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Mode'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (nameController.text.isEmpty) return;
                                final modes = modeControllers
                                    .where((mc) => mc.name.text.isNotEmpty)
                                    .map((mc) => GameMode(
                                          name: mc.name.text,
                                          estimatedMinutes: int.tryParse(mc.duration.text) ?? 30,
                                          commitmentType: GameCommitmentType.commitment,
                                          isCompetitive: true,
                                        ))
                                    .toList();

                                if (modes.isEmpty) return;

                                final game = GameProfile(
                                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameController.text,
                                  category: GameCategory.competitive,
                                  iconName: 'custom',
                                  color: 0xFF7C5CFF,
                                  modes: modes,
                                  isCustom: true,
                                  isSelected: true,
                                );

                                ref.read(userGamesProvider.notifier).addCustomGame(game);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Add Game to My List'),
                            ),
                          ),
                        ],
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
}

class _ModeController {
  final TextEditingController name;
  final TextEditingController duration;

  _ModeController({required this.name, required this.duration});
}

class _GameCard extends ConsumerStatefulWidget {
  final GameProfile game;

  const _GameCard({required this.game});

  @override
  ConsumerState<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<_GameCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final gameColor = Color(game.color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: game.isSelected
              ? gameColor.withValues(alpha: 0.4)
              : (Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight),
          width: game.isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                GameIconWidget(iconName: game.iconName, size: 38, fallbackColor: game.color),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${game.enabledModes.length}/${game.modes.length} modes active • ${game.category.label}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                Checkbox(
                  value: game.isSelected,
                  activeColor: gameColor,
                  onChanged: (_) {
                    ref.read(userGamesProvider.notifier).toggleGameSelected(game.id);
                  },
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded, color: AppColors.textMuted, size: 20),
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),

          // Modes expansion
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  ...game.modes.map((mode) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: mode.isEnabled,
                              activeColor: gameColor,
                              onChanged: (_) {
                                ref.read(userGamesProvider.notifier).toggleModeEnabled(game.id, mode.name);
                              },
                            ),
                            Expanded(
                              child: Text(
                                mode.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: mode.isEnabled ? FontWeight.w600 : FontWeight.w400,
                                  color: mode.isEnabled
                                      ? Theme.of(context).colorScheme.onSurface
                                      : (Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                mode.commitmentType == GameCommitmentType.flexible ? 'Flexible' : '~${mode.estimatedMinutes}m (${mode.minMinutes}–${mode.maxMinutes}m)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
