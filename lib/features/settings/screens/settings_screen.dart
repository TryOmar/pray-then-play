import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/constants/prayer_constants.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcMethod = ref.watch(calculationMethodProvider);
    final asrMethod = ref.watch(asrMethodProvider);
    final protectionLevel = ref.watch(protectionLevelProvider);
    final currentTheme = ref.watch(gamingThemeProvider);
    final jumuahMode = ref.watch(jumuahModeProvider);
    final fajrMode = ref.watch(fajrModeProvider);
    final userGames = ref.watch(userGamesProvider);
    final city = StorageService.cityName;
    final country = StorageService.countryName;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure your gaming schedule and prayer discipline',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // LOCATION
                  _SettingsSection(
                    title: 'PRAYER LOCATION',
                    children: [
                      _SettingsTile(
                        icon: Icons.location_on_rounded,
                        title: '$city, $country',
                        subtitle: 'Coordinates: ${StorageService.latitude?.toStringAsFixed(2)}, ${StorageService.longitude?.toStringAsFixed(2)}',
                        trailing: TextButton(
                          onPressed: () => _showLocationOptions(context, ref),
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PRAYER CALCULATION & MADHHAB
                  _SettingsSection(
                    title: 'CALCULATION & MADHHAB',
                    children: [
                      _SettingsTile(
                        icon: Icons.calculate_rounded,
                        title: 'Calculation Method',
                        subtitle: calcMethod.displayName,
                        onTap: () => _showMethodPicker(context, ref),
                      ),
                      const Divider(height: 1, indent: 50),
                      _SettingsTile(
                        icon: Icons.access_time_rounded,
                        title: 'Asr Calculation',
                        subtitle: asrMethod.displayName,
                        onTap: () => _showAsrPicker(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PRAYER PROTECTION & SAFETY BUFFER
                  _SettingsSection(
                    title: 'PRAYER PROTECTION & BUFFER',
                    children: [
                      _SettingsTile(
                        icon: Icons.shield_rounded,
                        title: 'Safety Margin',
                        subtitle: '${protectionLevel.label} (${protectionLevel.bufferMinutes} min buffer)',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentTheme.primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${protectionLevel.bufferMinutes}m buffer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: currentTheme.primaryAccent,
                            ),
                          ),
                        ),
                        onTap: () => _showProtectionPicker(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // MY GAMES & MODES
                  _SettingsSection(
                    title: 'MY GAMES & MODES (${userGames.where((g) => g.isSelected).length} active)',
                    children: [
                      _SettingsTile(
                        icon: Icons.sports_esports_rounded,
                        title: 'Configure Games & Match Modes',
                        subtitle: 'Manage enabled modes and durations',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        onTap: () => context.push('/games'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // GAMING THEME
                  _SettingsSection(
                    title: 'GAMING THEME',
                    children: [
                      _SettingsTile(
                        icon: Icons.palette_rounded,
                        title: currentTheme.displayName,
                        subtitle: currentTheme.description,
                        trailing: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: currentTheme.primaryAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () => _showThemePicker(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SPECIAL MODES
                  _SettingsSection(
                    title: 'SPECIAL MODES',
                    children: [
                      _SettingsToggle(
                        icon: Icons.event_rounded,
                        title: "Jumu'ah Mode",
                        subtitle: 'Extra early reminders on Friday for Jumu\'ah prayer',
                        value: jumuahMode,
                        onChanged: (_) => ref.read(jumuahModeProvider.notifier).toggle(),
                      ),
                      const Divider(height: 1, indent: 50),
                      _SettingsToggle(
                        icon: Icons.dark_mode_rounded,
                        title: 'Fajr Protection Mode',
                        subtitle: 'Late-night gaming reminders to safeguard Dawn prayer',
                        value: fajrMode,
                        onChanged: (_) => ref.read(fajrModeProvider.notifier).toggle(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ONBOARDING RESET
                  _SettingsSection(
                    title: 'SETUP WIZARD',
                    children: [
                      _SettingsTile(
                        icon: Icons.refresh_rounded,
                        title: 'Re-run Onboarding Setup',
                        subtitle: 'Reconfigure location, games, modes and preferences',
                        onTap: () => context.go('/onboarding'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ABOUT
                  const _SettingsSection(
                    title: 'ABOUT',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'GamerSalah',
                        subtitle: 'v${AppConstants.version} • ${AppConstants.tagline}',
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change Prayer Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.my_location_rounded, color: AppColors.primaryCyan),
              title: const Text('Use GPS Location'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final pos = await LocationService.getCurrentPosition();
                  final city = await LocationService.getCityName(pos.latitude, pos.longitude);
                  await StorageService.setLocation(pos.latitude, pos.longitude, city);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location updated: $city')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GPS error: $e')));
                  }
                }
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.search_rounded, color: AppColors.primaryCyan),
              title: const Text('Search City Database'),
              onTap: () {
                Navigator.pop(ctx);
                _showCitySearch(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySearch(BuildContext context, WidgetRef ref) {
    List<CityInfo> filtered = CityDatabase.popularCities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Search City Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search city...', prefixIcon: Icon(Icons.search_rounded)),
                onChanged: (q) {
                  setModalState(() {
                    filtered = CityDatabase.search(q);
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.country),
                      onTap: () async {
                        await StorageService.setLocation(c.latitude, c.longitude, c.name, country: c.country);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    int filterIndex = 0; // 0: All, 1: Dark, 2: Light

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filteredThemes = AppGamingTheme.values.where((t) {
            if (filterIndex == 1) return !t.isLight;
            if (filterIndex == 2) return t.isLight;
            return true;
          }).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                    const Text('Gaming Themes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a curated Dark or Light mode palette for your dashboard.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),

                // Light / Dark Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All (11)', filterIndex == 0, () => setModalState(() => filterIndex = 0), context),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dark Modes (8)', filterIndex == 1, () => setModalState(() => filterIndex = 1), context),
                    const SizedBox(width: 8),
                    _buildFilterChip('Light Modes (3)', filterIndex == 2, () => setModalState(() => filterIndex = 2), context),
                  ],
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: ListView.separated(
                    itemCount: filteredThemes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final theme = filteredThemes[index];
                      final isSelected = ref.watch(gamingThemeProvider) == theme;
                      return GestureDetector(
                        onTap: () {
                          ref.read(gamingThemeProvider.notifier).setTheme(theme);
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryAccent
                                  : theme.borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primaryAccent.withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Visual Palette Capsule Preview
                              Container(
                                width: 56,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: theme.borderColor),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      right: 6,
                                      bottom: 6,
                                      child: Container(
                                        width: 24,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: theme.surfaceElevated,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: theme.primaryAccent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primaryAccent.withValues(alpha: 0.5),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          theme.displayName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? theme.primaryAccent : theme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: theme.isLight ? Colors.blue.withValues(alpha: 0.12) : Colors.purple.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            theme.isLight ? 'LIGHT' : 'DARK',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: theme.isLight ? Colors.blue : Colors.purpleAccent,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      theme.description,
                                      style: TextStyle(fontSize: 12, color: theme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.primaryAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded, size: 14, color: theme.buttonTextColor),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primary : Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  void _showMethodPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Calculation Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: CalculationMethodType.values.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceHighlight),
                itemBuilder: (context, index) {
                  final method = CalculationMethodType.values[index];
                  final isSelected = ref.watch(calculationMethodProvider) == method;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    title: Text(
                      method.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20)
                        : null,
                    onTap: () {
                      ref.read(calculationMethodProvider.notifier).setMethod(method);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAsrPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                  color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Asr Madhhab Calculation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...AsrMethodType.values.map((m) {
              final isSelected = ref.watch(asrMethodProvider) == m;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                title: Text(
                  m.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(m.description, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted)),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20) : null,
                onTap: () {
                  ref.read(asrMethodProvider.notifier).setMethod(m);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showProtectionPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                  color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Safety Margin / Protection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...ProtectionLevel.values.map((level) {
              final isSelected = ref.watch(protectionLevelProvider) == level;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                title: Text(
                  '${level.label} (${level.bufferMinutes} min buffer)',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(level.description, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted)),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20) : null,
                onTap: () {
                  ref.read(protectionLevelProvider.notifier).setLevel(level);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrim)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: textSec)),
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: textSec, size: 20) : null),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
