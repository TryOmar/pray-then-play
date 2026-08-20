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
                            'My Games & Activities',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Customize activity durations, pauseability, and add custom modes',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddGameDialog(context, ref),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Game'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (userGames.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: GlassmorphicDecoration.card(context: context),
                    child: Column(
                      children: [
                        const Icon(Icons.sports_esports_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No Games in Library',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add your favorite games and servers from our catalog or create custom ones.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddGameDialog(context, ref),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Browse Games Catalog'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = userGames[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
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
    GameCategory selectedCategory = GameCategory.casual;
    final activityControllers = <_ActivityDraftController>[
      _ActivityDraftController(
        name: TextEditingController(text: 'Main Session'),
        duration: TextEditingController(text: '30'),
        canPause: true,
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
                g.category.label
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
          }).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
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
                      color: Theme.of(context).dividerTheme.color ??
                          AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Add to Library',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
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
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.15)
                                : Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor ??
                                    AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeTab == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerTheme.color ??
                                      AppColors.surfaceHighlight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Predefined Catalog (${GameData.defaultCatalog.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: activeTab == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: activeTab == 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color ??
                                        AppColors.textMuted,
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
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.15)
                                : Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor ??
                                    AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeTab == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerTheme.color ??
                                      AppColors.surfaceHighlight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+ Custom Game',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: activeTab == 1
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: activeTab == 1
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color ??
                                        AppColors.textMuted,
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
                      hintText:
                          'Search catalog (Minecraft, Valorant, FiveM...)',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () =>
                                  setModalState(() => searchQuery = ''),
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
                        final isAlreadyAdded = userGames
                            .any((g) => g.id == game.id && g.isSelected);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor ??
                                AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAlreadyAdded
                                  ? AppColors.successGreen
                                      .withValues(alpha: 0.3)
                                  : (Theme.of(context).dividerTheme.color ??
                                      AppColors.surfaceHighlight),
                            ),
                          ),
                          child: Row(
                            children: [
                              GameIconWidget(
                                  iconName: game.iconName,
                                  size: 36,
                                  fallbackColor: game.color),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${game.activities.length} activities • ${game.category.label}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color ??
                                            AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(userGamesProvider.notifier)
                                      .addCatalogGame(game);
                                  setModalState(() {});
                                },
                                icon: Icon(
                                  isAlreadyAdded
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  size: 16,
                                ),
                                label: Text(isAlreadyAdded ? 'Added' : 'Add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyAdded
                                      ? AppColors.successGreen
                                      : Theme.of(context).primaryColor,
                                  foregroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                            decoration: const InputDecoration(
                              labelText: 'Game / Server Name',
                              hintText:
                                  'e.g. My Friend\'s SMP, FiveM RP, Chess',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Category:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Casual / Flexible'),
                                selected:
                                    selectedCategory == GameCategory.casual,
                                onSelected: (val) => setModalState(
                                    () => selectedCategory = GameCategory.casual),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Competitive'),
                                selected: selectedCategory ==
                                    GameCategory.competitive,
                                onSelected: (val) => setModalState(() =>
                                    selectedCategory =
                                        GameCategory.competitive),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ACTIVITIES & DURATIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...activityControllers.asMap().entries.map((entry) {
                            final i = entry.key;
                            final ac = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor ??
                                    AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: ac.name,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Activity name (e.g. Skyblock)',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: ac.duration,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: 'Typical min',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      if (i > 0)
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              size: 18,
                                              color: AppColors.dangerRed),
                                          onPressed: () => setModalState(
                                              () => activityControllers
                                                  .removeAt(i)),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: ac.canPause,
                                        onChanged: (val) => setModalState(
                                            () => ac.canPause = val ?? false),
                                      ),
                                      const Text('Can pause / exit anytime',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                activityControllers.add(_ActivityDraftController(
                                  name: TextEditingController(),
                                  duration: TextEditingController(text: '30'),
                                  canPause: true,
                                ));
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('+ Add Another Activity'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;
                                final gameId =
                                    'custom_${DateTime.now().millisecondsSinceEpoch}';

                                final acts = activityControllers
                                    .where((ac) => ac.name.text.trim().isNotEmpty)
                                    .map((ac) {
                                  final dur =
                                      int.tryParse(ac.duration.text.trim()) ??
                                          30;
                                  return GameActivity(
                                    id: '${gameId}_${DateTime.now().millisecondsSinceEpoch}',
                                    gameId: gameId,
                                    name: ac.name.text.trim(),
                                    typicalDuration: dur,
                                    minMinutes: dur > 10 ? dur - 5 : dur,
                                    maxMinutes: dur > 10 ? dur + 15 : dur + 5,
                                    canPause: ac.canPause,
                                    requiresCompletion: !ac.canPause,
                                    isCompetitive:
                                        selectedCategory == GameCategory.competitive,
                                    commitmentType: ac.canPause
                                        ? GameCommitmentType.flexible
                                        : GameCommitmentType.commitment,
                                    isCustom: true,
                                  );
                                }).toList();

                                if (acts.isEmpty) return;

                                final game = GameProfile(
                                  id: gameId,
                                  name: name,
                                  category: selectedCategory,
                                  iconName: 'custom',
                                  color: 0xFF00E5FF,
                                  activities: acts,
                                  isCustom: true,
                                  isSelected: true,
                                );

                                ref
                                    .read(userGamesProvider.notifier)
                                    .addCustomGame(game);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Add Game to My Library'),
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

class _ActivityDraftController {
  final TextEditingController name;
  final TextEditingController duration;
  bool canPause;

  _ActivityDraftController({
    required this.name,
    required this.duration,
    this.canPause = false,
  });
}

class _GameCard extends ConsumerStatefulWidget {
  final GameProfile game;

  const _GameCard({required this.game});

  @override
  ConsumerState<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<_GameCard> {
  // Start expanded by default so activities, edit buttons, and add buttons are immediately visible
  bool _expanded = true;

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
              ? gameColor.withValues(alpha: 0.45)
              : (Theme.of(context).dividerTheme.color ??
                  AppColors.surfaceHighlight),
          width: game.isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                GameIconWidget(
                    iconName: game.iconName,
                    size: 40,
                    fallbackColor: game.color),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              game.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            if (game.isCustom) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCyan
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Custom',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryCyan,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.enabledActivities.length}/${game.activities.length} activities active • ${game.category.label}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add activity to ${game.name}',
                  onPressed: () => _showAddActivityDialog(context, game),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.primaryCyan, size: 18),
                  ),
                ),
                Checkbox(
                  value: game.isSelected,
                  activeColor: gameColor,
                  onChanged: (_) {
                    ref
                        .read(userGamesProvider.notifier)
                        .toggleGameSelected(game.id);
                  },
                ),
                if (game.isCustom)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.dangerRed),
                    onPressed: () {
                      ref
                          .read(userGamesProvider.notifier)
                          .removeGame(game.id);
                    },
                  ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.textMuted, size: 20),
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),

          // Activities expansion
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'ACTIVITIES & MODES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showAddActivityDialog(context, game),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 14, color: AppColors.primaryCyan),
                              SizedBox(width: 4),
                              Text(
                                'Add Activity',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...game.activities.map((activity) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: activity.isEnabled
                                ? (Theme.of(context).dividerTheme.color ??
                                    AppColors.surfaceHighlight)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: activity.isEnabled,
                              activeColor: gameColor,
                              onChanged: (_) {
                                ref
                                    .read(userGamesProvider.notifier)
                                    .toggleActivityEnabled(
                                        game.id, activity.id);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activity.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: activity.isEnabled
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: activity.isEnabled
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      if (activity.isCustom) ...[
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryCyan
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            'Custom',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryCyan),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (activity.canPause &&
                                          !activity.requiresCompletion) ...[
                                        const Text(
                                          'Pauseable',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.successGreen),
                                        ),
                                        const Text(' • ',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textMuted)),
                                      ],
                                      Text(
                                        '~${activity.typicalDuration}m (${activity.minMinutes}–${activity.maxMinutes}m)',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  if (activity.notes != null &&
                                      activity.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Notes: ${activity.notes}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Prominent Edit Button
                            OutlinedButton.icon(
                              onPressed: () => _showEditActivityDialog(
                                  context, game, activity),
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (activity.isCustom) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 16, color: AppColors.dangerRed),
                                onPressed: () {
                                  ref
                                      .read(userGamesProvider.notifier)
                                      .deleteActivity(game.id, activity.id);
                                },
                              ),
                            ],
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),
                  // Large Add Activity Button at bottom of card
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddActivityDialog(context, game),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 16, color: AppColors.primaryCyan),
                      label: Text('+ Add Activity to ${game.name}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryCyan,
                        side: BorderSide(
                            color: AppColors.primaryCyan
                                .withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, GameProfile game) {
    final nameCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '30');
    final minCtrl = TextEditingController(text: '20');
    final maxCtrl = TextEditingController(text: '45');
    final notesCtrl = TextEditingController();
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
              Text(
                'Add Activity to ${game.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Activity Name (e.g. Skyblock, Heist, Career)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Typical (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Can Pause Safely?'),
                subtitle: const Text('Can exit or save anytime without penalty'),
                value: canPause,
                onChanged: (v) => setModalState(() => canPause = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Competitive / Match Locked?'),
                value: isCompetitive,
                onChanged: (v) => setModalState(() => isCompetitive = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Custom Notes (Optional)',
                  hintText: 'e.g. Weekend server with squad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final dur = int.tryParse(durCtrl.text.trim()) ?? 30;
                    final minM = int.tryParse(minCtrl.text.trim()) ?? (dur - 5);
                    final maxM = int.tryParse(maxCtrl.text.trim()) ?? (dur + 10);

                    final act = GameActivity(
                      id: '${game.id}_${DateTime.now().millisecondsSinceEpoch}',
                      gameId: game.id,
                      name: name,
                      typicalDuration: dur,
                      minMinutes: minM,
                      maxMinutes: maxM,
                      canPause: canPause,
                      requiresCompletion: !canPause,
                      isCompetitive: isCompetitive,
                      commitmentType: canPause
                          ? GameCommitmentType.flexible
                          : GameCommitmentType.commitment,
                      isCustom: true,
                      notes: notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : null,
                    );

                    ref
                        .read(userGamesProvider.notifier)
                        .addCustomActivity(game.id, act);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditActivityDialog(
      BuildContext context, GameProfile game, GameActivity activity) {
    final nameCtrl = TextEditingController(text: activity.name);
    final durCtrl =
        TextEditingController(text: activity.typicalDuration.toString());
    final minCtrl = TextEditingController(text: activity.minMinutes.toString());
    final maxCtrl = TextEditingController(text: activity.maxMinutes.toString());
    final notesCtrl = TextEditingController(text: activity.notes ?? '');
    bool canPause = activity.canPause;
    bool isCompetitive = activity.isCompetitive;

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
              Text(
                'Edit ${activity.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Typical (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max (min)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Can Pause Safely?'),
                subtitle: const Text('Can exit or save anytime without penalty'),
                value: canPause,
                onChanged: (v) => setModalState(() => canPause = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Competitive / Match Locked?'),
                value: isCompetitive,
                onChanged: (v) => setModalState(() => isCompetitive = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Custom Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final dur = int.tryParse(durCtrl.text.trim()) ??
                        activity.typicalDuration;
                    final minM =
                        int.tryParse(minCtrl.text.trim()) ?? activity.minMinutes;
                    final maxM =
                        int.tryParse(maxCtrl.text.trim()) ?? activity.maxMinutes;

                    final updated = activity.copyWith(
                      name: name,
                      typicalDuration: dur,
                      minMinutes: minM,
                      maxMinutes: maxM,
                      canPause: canPause,
                      requiresCompletion: !canPause,
                      isCompetitive: isCompetitive,
                      commitmentType: canPause
                          ? GameCommitmentType.flexible
                          : GameCommitmentType.commitment,
                      notes: notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : null,
                    );

                    ref
                        .read(userGamesProvider.notifier)
                        .updateActivity(game.id, updated);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
