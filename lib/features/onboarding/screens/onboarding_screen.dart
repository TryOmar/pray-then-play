import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/constants/game_data.dart';
import '../../../core/constants/prayer_constants.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/game_icon_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 2: Location & Prayer Settings
  bool _locationLoading = false;
  bool _locationDone = false;
  String _cityName = 'Makkah';
  String _countryName = 'Saudi Arabia';
  double _latitude = 21.4225;
  double _longitude = 39.8262;
  CalculationMethodType _calcMethod = CalculationMethodType.muslimWorldLeague;
  AsrMethodType _asrMethod = AsrMethodType.standard;

  // Step 3 & 4: Games & Modes
  late List<GameProfile> _catalogGames;
  String _gameSearchQuery = '';

  // Step 5: Protection level
  ProtectionLevel _protectionLevel = ProtectionLevel.balanced;

  // Step 6: Gaming Theme
  AppGamingTheme _selectedTheme = AppGamingTheme.cyber;

  @override
  void initState() {
    super.initState();
    _catalogGames = GameData.defaultCatalog.map((g) {
      // By default select top 3 games
      final isDefault = g.id == 'valorant' || g.id == 'league_of_legends' || g.id == 'minecraft';
      return g.copyWith(isSelected: isDefault);
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      final next = _currentPage + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage = next);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      final prev = _currentPage - 1;
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage = prev);
    }
  }

  // Location Methods
  Future<void> _getLocationGPS() async {
    setState(() => _locationLoading = true);
    try {
      final permission = await LocationService.requestPermission();
      if (permission.toString().contains('denied')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS permission denied. You can search or select a city below.')),
          );
        }
        setState(() => _locationLoading = false);
        return;
      }

      final position = await LocationService.getCurrentPosition();
      final city = await LocationService.getCityName(position.latitude, position.longitude);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _cityName = city;
        _locationDone = true;
        _locationLoading = false;
      });
    } catch (e) {
      setState(() => _locationLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get GPS: $e. You can choose your city directly.')),
        );
      }
    }
  }

  void _showCitySearchDialog() {
    final searchController = TextEditingController();
    List<CityInfo> filtered = CityDatabase.popularCities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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
                  const Text(
                    'Search City',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type city name (e.g. Cairo, Riyadh, London...)',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
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
                    final city = filtered[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_city_rounded, size: 18, color: AppColors.primaryCyan),
                      ),
                      title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(city.country, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      onTap: () {
                        setState(() {
                          _cityName = city.name;
                          _countryName = city.country;
                          _latitude = city.latitude;
                          _longitude = city.longitude;
                          _locationDone = true;
                        });
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

  void _showManualCoordinatesDialog() {
    final latController = TextEditingController(text: _latitude.toString());
    final lngController = TextEditingController(text: _longitude.toString());
    final cityController = TextEditingController(text: _cityName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
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
            const Text('Enter Location Coordinates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City Name')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: latController, decoration: const InputDecoration(labelText: 'Latitude'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: lngController, decoration: const InputDecoration(labelText: 'Longitude'))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final lat = double.tryParse(latController.text) ?? 21.4225;
                  final lng = double.tryParse(lngController.text) ?? 39.8262;
                  setState(() {
                    _latitude = lat;
                    _longitude = lng;
                    _cityName = cityController.text.isNotEmpty ? cityController.text : 'Custom Location';
                    _locationDone = true;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    // Save location
    await StorageService.setLocation(_latitude, _longitude, _cityName, country: _countryName);
    await StorageService.setCalculationMethod(_calcMethod);
    await StorageService.setAsrMethod(_asrMethod);
    await StorageService.setProtectionLevel(_protectionLevel);
    await StorageService.setGamingTheme(_selectedTheme);

    // Save configured user games
    final selectedGames = _catalogGames.where((g) => g.isSelected).toList();
    ref.read(userGamesProvider.notifier).setGames(selectedGames);
    ref.read(gamingThemeProvider.notifier).setTheme(_selectedTheme);
    ref.read(calculationMethodProvider.notifier).setMethod(_calcMethod);
    ref.read(asrMethodProvider.notifier).setMethod(_asrMethod);
    ref.read(protectionLevelProvider.notifier).setLevel(_protectionLevel);

    await StorageService.setOnboardingComplete(true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      onPressed: _prevPage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: List.generate(6, (index) {
                        final isPassed = index <= _currentPage;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isPassed ? _selectedTheme.primaryAccent : AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildLocationPage(),
                  _buildGamesSelectionPage(),
                  _buildModesCustomizationPage(),
                  _buildProtectionPage(),
                  _buildThemePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Welcome
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 84,
            height: 84,
            decoration: GlassmorphicDecoration.neonCard(
              glowColor: _selectedTheme.primaryAccent,
              borderRadius: 22,
            ),
            child: Icon(
              Icons.mosque_rounded,
              size: 42,
              color: _selectedTheme.primaryAccent,
            ),
          ),
          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [_selectedTheme.primaryAccent, _selectedTheme.textPrimary]).createShader(bounds),
            child: Text(
              'GamerSalah',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: _selectedTheme.textPrimary,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Protect your Salah. Enjoy your games.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _selectedTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Let\'s configure your gaming schedule so we can give you useful, prayer-aware recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _selectedTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          _PhilosophyTile(
            icon: Icons.access_time_filled_rounded,
            title: 'Know your safe gaming windows',
            subtitle: 'Calculates exact uninterrupted gaming time before next prayer',
            color: _selectedTheme.primaryAccent,
          ),
          const SizedBox(height: 12),
          _PhilosophyTile(
            icon: Icons.shield_rounded,
            title: 'Smart "Can I Queue?" warnings',
            subtitle: 'Prevents getting locked into ranked matches that overlap with Salah',
            color: _selectedTheme.primaryAccent,
          ),
          const SizedBox(height: 12),
          _PhilosophyTile(
            icon: Icons.sports_esports_rounded,
            title: 'Personalized to what you play',
            subtitle: 'Only suggests game modes from your selected game library',
            color: _selectedTheme.primaryAccent,
          ),

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTheme.primaryAccent,
                foregroundColor: _selectedTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Location & Calculation
  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_rounded, size: 40, color: AppColors.primaryCyan),
          const SizedBox(height: 10),
          const Text('Prayer Location', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Your prayer times will be calculated according to your location and preferred method.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Location Selection Cards
          if (_locationDone) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: GlassmorphicDecoration.neonCard(
                glowColor: AppColors.successGreen,
                glowIntensity: 0.15,
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location Selected', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('$_cityName, $_countryName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _locationDone = false),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          ] else ...[
            _LocationOptionButton(
              icon: Icons.my_location_rounded,
              title: 'Use my current location (GPS)',
              subtitle: _locationLoading ? 'Detecting coordinates...' : 'Fastest & most accurate',
              isLoading: _locationLoading,
              onTap: _getLocationGPS,
            ),
            const SizedBox(height: 10),
            _LocationOptionButton(
              icon: Icons.search_rounded,
              title: 'Search for my city',
              subtitle: 'Select from 50+ major cities without GPS',
              onTap: _showCitySearchDialog,
            ),
            const SizedBox(height: 10),
            _LocationOptionButton(
              icon: Icons.edit_location_alt_rounded,
              title: 'Enter location manually',
              subtitle: 'Specify custom latitude and longitude',
              onTap: _showManualCoordinatesDialog,
            ),
          ],

          const SizedBox(height: 24),

          // Calculation Method
          const Text('CALCULATION METHOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<CalculationMethodType>(
              value: _calcMethod,
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              items: CalculationMethodType.values.map((m) => DropdownMenuItem(value: m, child: Text(m.displayName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _calcMethod = v);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Asr Madhhab
          const Text('ASR CALCULATION (MADHHAB)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<AsrMethodType>(
              value: _asrMethod,
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              items: AsrMethodType.values.map((m) => DropdownMenuItem(value: m, child: Text(m.displayName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _asrMethod = v);
              },
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _locationDone ? _nextPage : () {
                // If user didn't explicitly pick GPS, default to Makkah
                setState(() => _locationDone = true);
                _nextPage();
              },
              child: const Text('Continue to Games'),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Choose Your Games
  Widget _buildGamesSelectionPage() {
    final competitiveGames = _catalogGames
        .where((g) => g.category == GameCategory.competitive &&
            (g.name.toLowerCase().contains(_gameSearchQuery.toLowerCase())))
        .toList();

    final casualGames = _catalogGames
        .where((g) => g.category == GameCategory.casual &&
            (g.name.toLowerCase().contains(_gameSearchQuery.toLowerCase())))
        .toList();

    final selectedCount = _catalogGames.where((g) => g.isSelected).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What do you play?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Select your games. We\'ll only recommend modes from what you actually play.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search games...',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
            ),
            onChanged: (q) => setState(() => _gameSearchQuery = q),
          ),
          const SizedBox(height: 14),

          // Categorized Game List
          Expanded(
            child: ListView(
              children: [
                if (competitiveGames.isNotEmpty) ...[
                  const _CategoryHeading(
                    title: 'COMPETITIVE & MATCH-BASED',
                    subtitle: 'Penalty for leaving · Requires safe queue warnings',
                    color: AppColors.dangerRed,
                  ),
                  const SizedBox(height: 8),
                  ...competitiveGames.map((game) => _GameSelectRow(
                        game: game,
                        onToggle: () {
                          setState(() {
                            final idx = _catalogGames.indexWhere((g) => g.id == game.id);
                            if (idx != -1) {
                              _catalogGames[idx] = game.copyWith(isSelected: !game.isSelected);
                            }
                          });
                        },
                      )),
                  const SizedBox(height: 16),
                ],

                if (casualGames.isNotEmpty) ...[
                  const _CategoryHeading(
                    title: 'CASUAL & FLEXIBLE',
                    subtitle: 'Pause or quit anytime · Safe for shorter gaps',
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 8),
                  ...casualGames.map((game) => _GameSelectRow(
                        game: game,
                        onToggle: () {
                          setState(() {
                            final idx = _catalogGames.indexWhere((g) => g.id == game.id);
                            if (idx != -1) {
                              _catalogGames[idx] = game.copyWith(isSelected: !game.isSelected);
                            }
                          });
                        },
                      )),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedCount > 0 ? _nextPage : null,
              child: Text(selectedCount > 0 ? 'Customize Modes ($selectedCount selected)' : 'Select at least 1 game'),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Customize Activities & Modes
  Widget _buildModesCustomizationPage() {
    final selectedGames = _catalogGames.where((g) => g.isSelected).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activities & Modes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Enable the activities you actually play. Uncheck modes you don\'t play.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: selectedGames.length,
              itemBuilder: (context, index) {
                final game = selectedGames[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceHighlight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GameIconWidget(iconName: game.iconName, size: 28, fallbackColor: game.color),
                          const SizedBox(width: 10),
                          Text(game.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...game.modes.map((mode) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: mode.isEnabled,
                                activeColor: Color(game.color),
                                onChanged: (val) {
                                  setState(() {
                                    final gameIdx = _catalogGames.indexWhere((g) => g.id == game.id);
                                    if (gameIdx != -1) {
                                      final updatedModes = game.modes.map((m) {
                                        if (m.name == mode.name) {
                                          return m.copyWith(isEnabled: val ?? true);
                                        }
                                        return m;
                                      }).toList();
                                      _catalogGames[gameIdx] = game.copyWith(modes: updatedModes);
                                    }
                                  });
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
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Configure Protection Level'),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 5: Protection Level & Safety Margin
  Widget _buildProtectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, size: 40, color: AppColors.primaryCyan),
          const SizedBox(height: 10),
          const Text('Prayer Protection', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Choose how conservative the queue warning system should be.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...ProtectionLevel.values.map((level) {
            final isSelected = _protectionLevel == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _protectionLevel = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedTheme.primaryAccent.withValues(alpha: 0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _selectedTheme.primaryAccent : AppColors.surfaceHighlight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? _selectedTheme.primaryAccent : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(level.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _selectedTheme.primaryAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    level.badge,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _selectedTheme.primaryAccent),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(level.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Choose Gaming Theme'),
            ),
          ),
        ],
      ),
    );
  }

  int _themeFilterIndex = 0;

  // STEP 6: Gaming Theme
  Widget _buildThemePage() {
    final filteredThemes = AppGamingTheme.values.where((t) {
      if (_themeFilterIndex == 1) return !t.isLight;
      if (_themeFilterIndex == 2) return t.isLight;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.palette_rounded, size: 40, color: AppColors.primaryCyan),
          const SizedBox(height: 10),
          const Text('Choose Your Theme', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Select a professional gaming-inspired visual theme for your dashboard.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Filter chips
          Row(
            children: [
              _buildOnboardingFilterChip('All (11)', _themeFilterIndex == 0, () => setState(() => _themeFilterIndex = 0)),
              const SizedBox(width: 8),
              _buildOnboardingFilterChip('Dark (8)', _themeFilterIndex == 1, () => setState(() => _themeFilterIndex = 1)),
              const SizedBox(width: 8),
              _buildOnboardingFilterChip('Light (3)', _themeFilterIndex == 2, () => setState(() => _themeFilterIndex = 2)),
            ],
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: filteredThemes.map((theme) {
              final isSelected = _selectedTheme == theme;
              return GestureDetector(
                onTap: () => setState(() => _selectedTheme = theme),
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
                              color: theme.primaryAccent.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 18,
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.borderColor),
                            ),
                            child: Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.primaryAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: theme.primaryAccent, size: 16),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                theme.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? theme.primaryAccent : theme.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.isLight ? Colors.blue.withValues(alpha: 0.15) : Colors.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  theme.isLight ? 'L' : 'D',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: theme.isLight ? Colors.blue : Colors.purpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            theme.tagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: theme.secondaryAccent, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTheme.primaryAccent,
                foregroundColor: _selectedTheme.buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Using GamerSalah'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _selectedTheme.primaryAccent.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _selectedTheme.primaryAccent : AppColors.surfaceHighlight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _selectedTheme.primaryAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PhilosophyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PhilosophyTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: GlassmorphicDecoration.card(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const _LocationOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCyan))
                  : Icon(icon, color: AppColors.primaryCyan, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _CategoryHeading({required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.2)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _GameSelectRow extends StatelessWidget {
  final GameProfile game;
  final VoidCallback onToggle;

  const _GameSelectRow({required this.game, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: game.isSelected ? Color(game.color).withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: game.isSelected ? Color(game.color) : AppColors.surfaceHighlight,
              width: game.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              GameIconWidget(iconName: game.iconName, size: 32, fallbackColor: game.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('${game.activities.length} activities & modes', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(
                game.isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: game.isSelected ? Color(game.color) : AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
