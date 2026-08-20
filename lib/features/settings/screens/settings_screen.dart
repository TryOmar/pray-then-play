import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/constants/prayer_constants.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/prayer_heatmap_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_logo_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcMethod = ref.watch(calculationMethodProvider);
    final asrMethod = ref.watch(asrMethodProvider);
    final protectionLevel = ref.watch(protectionLevelProvider);
    final currentTheme = ref.watch(effectiveThemeProvider);
    final manualTheme = ref.watch(gamingThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final jumuahMode = ref.watch(jumuahModeProvider);
    final fajrMode = ref.watch(fajrModeProvider);
    final is24Hour = ref.watch(timeFormatIs24HourProvider);
    final userGames = ref.watch(userGamesProvider);
    final city = StorageService.cityName;
    final country = StorageService.countryName;

    return Scaffold(
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
                    AppLogoWidget(
                      size: 34,
                      gamingTheme: currentTheme,
                      showGlow: false,
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
                        subtitle: StorageService.latitude != null && StorageService.longitude != null
                            ? 'Coordinates: ${StorageService.latitude!.toStringAsFixed(2)}, ${StorageService.longitude!.toStringAsFixed(2)}'
                            : 'Location configured',
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

                  // TIME DISPLAY & FORMAT
                  _SettingsSection(
                    title: 'TIME DISPLAY & FORMAT',
                    children: [
                      _SettingsTile(
                        icon: Icons.schedule_rounded,
                        title: 'Time Format',
                        subtitle: is24Hour
                            ? '24-Hour (e.g. 15:47)'
                            : '12-Hour (e.g. 03:47 PM)',
                        trailing: Switch.adaptive(
                          value: is24Hour,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            ref
                                .read(timeFormatIs24HourProvider.notifier)
                                .set24Hour(val);
                          },
                        ),
                        onTap: () {
                          ref
                              .read(timeFormatIs24HourProvider.notifier)
                              .toggle();
                        },
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

                  // MY GAMES & ACTIVITIES
                  _SettingsSection(
                    title: 'MY GAMES & ACTIVITIES (${userGames.where((g) => g.isSelected).length} active)',
                    children: [
                      _SettingsTile(
                        icon: Icons.sports_esports_rounded,
                        title: 'Configure Games & Activities',
                        subtitle: 'Manage enabled modes, typical durations, and custom servers',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        onTap: () => context.push('/games'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // THEME & VISUAL IDENTITY
                  _SettingsSection(
                    title: 'VISUAL IDENTITY & THEMES',
                    children: [
                      _SettingsTile(
                        icon: Icons.auto_mode_rounded,
                        title: 'Theme Mode',
                        subtitle: themeMode.description,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentTheme.primaryAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            themeMode.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: currentTheme.primaryAccent,
                            ),
                          ),
                        ),
                        onTap: () => _showThemeModePicker(context, ref),
                      ),
                      const Divider(height: 1, indent: 50),
                      _SettingsTile(
                        icon: Icons.palette_rounded,
                        title: manualTheme.displayName,
                        subtitle: '${manualTheme.tagline} • ${manualTheme.isLight ? 'Light' : 'Dark'}',
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: manualTheme.primaryAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          ),
                        ),
                        onTap: () => _showThemePicker(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SPECIAL MODES
                  _SettingsSection(
                    title: 'SPECIAL REMINDER MODES',
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

                  // SETUP WIZARD
                  _SettingsSection(
                    title: 'SETUP WIZARD',
                    children: [
                      _SettingsTile(
                        icon: Icons.refresh_rounded,
                        title: 'Re-run Onboarding Setup',
                        subtitle: 'Reconfigure location, prayer rules, games and preferences',
                        onTap: () => context.go('/onboarding'),
                      ),
                    ],
                  ),
                  // DATA MANAGEMENT
                  _SettingsSection(
                    title: 'DATA MANAGEMENT',
                    children: [
                      _SettingsTile(
                        icon: Icons.cleaning_services_rounded,
                        title: 'Clear History & Reset to Day 1',
                        subtitle: 'Erase all logged prayer records, streaks, and reset to clean slate',
                        titleColor: const Color(0xFFEF4444),
                        iconColor: const Color(0xFFEF4444),
                        onTap: () => _confirmResetData(context, ref),
                      ),
                      const Divider(height: 1, indent: 50),
                      _SettingsTile(
                        icon: Icons.science_outlined,
                        title: 'Load Sample Demo History',
                        subtitle: 'Populate 30-day realistic sample data for testing and previews',
                        onTap: () async {
                          await ref.read(prayerConsistencyProvider.notifier).loadDemoHistory();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sample 30-day prayer history loaded successfully!')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ABOUT PRAY THEN PLAY
                  _SettingsSection(
                    title: 'ABOUT',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: AppConstants.appName,
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

  void _confirmResetData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Prayer Data?'),
        content: const Text(
          'This will erase all recorded prayer logs, streaks, and reset your consistency heatmap to a clean Day 1 slate.\n\nYour location and game preferences will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(prayerConsistencyProvider.notifier).resetHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prayer history has been reset to Day 1.')),
                );
              }
            },
            child: const Text('Reset to Day 1'),
          ),
        ],
      ),
    );
  }

  void _showThemeModePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Padding(
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
              const Text('Theme Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              ...ThemeModeOption.values.map((mode) {
                final isSelected = ref.watch(themeModeProvider) == mode;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  title: Text(
                    mode.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setMode(mode);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    int filterIndex = 0; // 0: All, 1: Dark, 2: Light, 3: Special

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filteredThemes = AppGamingTheme.values.where((t) {
            if (filterIndex == 1) return !t.isLight && t != AppGamingTheme.tactical;
            if (filterIndex == 2) return t.isLight;
            if (filterIndex == 3) return t == AppGamingTheme.tactical || t == AppGamingTheme.oled;
            return true;
          }).toList();

          return Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
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
                      const Text('Theme Identities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Distinct environments with balanced light, dark, and gaming styles.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All (11)', filterIndex == 0, () => setModalState(() => filterIndex = 0), context),
                        const SizedBox(width: 8),
                        _buildFilterChip('Dark (5)', filterIndex == 1, () => setModalState(() => filterIndex = 1), context),
                        const SizedBox(width: 8),
                        _buildFilterChip('Light (5)', filterIndex == 2, () => setModalState(() => filterIndex = 2), context),
                        const SizedBox(width: 8),
                        _buildFilterChip('Special / OLED', filterIndex == 3, () => setModalState(() => filterIndex = 3), context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredThemes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final theme = filteredThemes[index];
                        final isSelected = ref.watch(gamingThemeProvider) == theme;
                        return _ThemeMiniPreviewCard(
                          theme: theme,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(gamingThemeProvider.notifier).setTheme(theme);
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
        },
      ),
    );
  }

  static Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  void _showLocationOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Padding(
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
              const Text('Change Prayer Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Icon(Icons.my_location_rounded, color: Theme.of(context).primaryColor),
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
                leading: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                title: const Text('Search City Database'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCitySearch(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCitySearch(BuildContext context, WidgetRef ref) {
    List<CityInfo> filtered = CityDatabase.popularCities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
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
      ),
    );
  }

  void _showMethodPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
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
                    color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight,
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
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight),
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
      ),
    );
  }

  void _showAsrPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Padding(
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
                  subtitle: Text(m.description,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20)
                      : null,
                  onTap: () {
                    ref.read(asrMethodProvider.notifier).setMethod(m);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
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
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Padding(
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
                  subtitle: Text(level.description,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 20)
                      : null,
                  onTap: () {
                    ref.read(protectionLevelProvider.notifier).setLevel(level);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeMiniPreviewCard extends StatelessWidget {
  final AppGamingTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeMiniPreviewCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primaryAccent : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryAccent.withValues(alpha: theme.isLight ? 0.15 : 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, Badge, Selector
            Row(
              children: [
                Text(
                  theme.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? theme.primaryAccent : theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.isLight
                        ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                        : Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    theme.isLight ? 'LIGHT' : (theme == AppGamingTheme.oled ? 'OLED' : 'DARK'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: theme.isLight ? const Color(0xFF2563EB) : Colors.purpleAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, size: 13, color: theme.buttonTextColor),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${theme.tagline} — ${theme.description}',
              style: TextStyle(fontSize: 11, color: theme.textMuted),
            ),
            const SizedBox(height: 10),

            // Live Simulated Mini Dashboard Preview Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.schedule_rounded, size: 16, color: theme.primaryAccent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ASR • 4:18 PM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '42m remaining',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Mini Safe Window Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Container(
                            height: 3,
                            color: theme.surfaceElevated,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.7,
                              child: Container(color: theme.tokens.semanticSuccess),
                            ),
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
        Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
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
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;
    final textPrim = titleColor ?? Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 18),
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
