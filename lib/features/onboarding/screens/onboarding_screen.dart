import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/constants/game_data.dart';
import '../../../core/constants/prayer_constants.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/models/game_profile.dart';
import '../../../core/providers/gaming_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_logo_widget.dart';
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
  AppGamingTheme _selectedTheme = AppGamingTheme.midnight;

  @override
  void initState() {
    super.initState();
    _catalogGames = GameData.defaultCatalog.map((g) {
      return g.copyWith(isSelected: false);
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
            SnackBar(content: Text(context.tr('gps_denied_msg'))),
          );
        }
        setState(() => _locationLoading = false);
        return;
      }

      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final city = await LocationService.getCityName(position.latitude, position.longitude);
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _cityName = city;
          _locationDone = true;
          _locationLoading = false;
        });
      } else {
        // Fallback to IP Geolocation on PC
        final ipLoc = await LocationService.fetchIpLocation();
        if (ipLoc != null) {
          setState(() {
            _latitude = ipLoc['latitude'] as double;
            _longitude = ipLoc['longitude'] as double;
            _cityName = ipLoc['city'] as String;
            _locationDone = true;
            _locationLoading = false;
          });
        } else {
          setState(() => _locationLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('gps_not_detected_msg'))),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _locationLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('gps_error_msg'))),
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
      backgroundColor: _selectedTheme.surface,
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
                    color: _selectedTheme.surfaceHighlight,
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
                          color: _selectedTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.location_city_rounded, size: 18, color: _selectedTheme.primaryAccent),
                      ),
                      title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(city.country, style: TextStyle(fontSize: 12, color: _selectedTheme.textMuted)),
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
      backgroundColor: _selectedTheme.surface,
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
                  color: _selectedTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.tr('enter_coords_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: cityController, decoration: InputDecoration(labelText: context.tr('city_name'))),
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
                child: Text(context.tr('save_location_btn')),
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

  void _showOnboardingLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final activeLang = ref.watch(appLanguageProvider);
          final theme = _selectedTheme;

          return Dialog(
            backgroundColor: theme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.borderColor),
            ),
            child: Container(
              width: 440,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.8,
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, size: 24, color: theme.primaryAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select Language / اختر اللغة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: theme.textMuted),
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your language for setup and daily gaming',
                    style: TextStyle(fontSize: 12, color: theme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: AppLanguage.values.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lang = AppLanguage.values[index];
                        final isSelected = lang == activeLang;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref.read(appLanguageProvider.notifier).setLanguage(lang);
                              Navigator.of(ctx, rootNavigator: true).pop();
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.primaryAccent.withValues(alpha: 0.14)
                                    : theme.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.primaryAccent
                                      : theme.borderColor,
                                  width: isSelected ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(lang.flag, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.nativeName,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? theme.primaryAccent
                                                : theme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          lang.englishName,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.primaryAccent,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: _selectedTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Top Step Progress Indicator & Language Pill
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
                      const SizedBox(width: 10),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showOnboardingLanguagePicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _selectedTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedTheme.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currentLanguage.flag, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(
                                  currentLanguage.nativeName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_drop_down_rounded, size: 16, color: _selectedTheme.textMuted),
                              ],
                            ),
                          ),
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
          const SizedBox(height: 24),
          AppLogoWidget(
            size: 80,
            gamingTheme: _selectedTheme,
            showGlow: false,
          ),
          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_selectedTheme.primaryAccent, _selectedTheme.textPrimary],
            ).createShader(bounds),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                context.tr('onboard_welcome_title'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _selectedTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            context.tr('onboard_plan_salah'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _selectedTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            context.tr('onboard_stay_time'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _selectedTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          _PhilosophyTile(
            icon: Icons.play_circle_outline_rounded,
            title: context.tr('onboard_f1_title'),
            subtitle: context.tr('onboard_f1_desc'),
            color: _selectedTheme.primaryAccent,
          ),
          const SizedBox(height: 12),
          _PhilosophyTile(
            icon: Icons.speed_rounded,
            title: context.tr('onboard_f2_title'),
            subtitle: context.tr('onboard_f2_desc'),
            color: _selectedTheme.primaryAccent,
          ),
          const SizedBox(height: 12),
          _PhilosophyTile(
            icon: Icons.shield_rounded,
            title: context.tr('onboard_f3_title'),
            subtitle: context.tr('onboard_f3_desc'),
            color: _selectedTheme.primaryAccent,
          ),

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTheme.primaryAccent,
                foregroundColor: _selectedTheme.buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                context.tr('btn_get_started'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
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
          Text(
            context.tr('step_location_title'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('step_location_subtitle'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                        Text(context.tr('location_selected'), style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('$_cityName, $_countryName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _locationDone = false),
                    child: Text(context.tr('change')),
                  ),
                ],
              ),
            ),
          ] else ...[
            _LocationOptionButton(
              icon: Icons.my_location_rounded,
              title: context.tr('btn_use_gps'),
              subtitle: _locationLoading ? context.tr('gps_detecting') : context.tr('gps_fastest'),
              isLoading: _locationLoading,
              onTap: _getLocationGPS,
            ),
            const SizedBox(height: 10),
            _LocationOptionButton(
              icon: Icons.search_rounded,
              title: context.tr('btn_choose_city'),
              subtitle: context.tr('city_select_sub'),
              onTap: _showCitySearchDialog,
            ),
            const SizedBox(height: 10),
            _LocationOptionButton(
              icon: Icons.edit_location_alt_rounded,
              title: context.tr('enter_location_manual'),
              subtitle: context.tr('enter_coords_sub'),
              onTap: _showManualCoordinatesDialog,
            ),
          ],

          const SizedBox(height: 24),

          // Calculation Method
          Text(
            context.tr('setting_calc_method').toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2),
          ),
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
              items: CalculationMethodType.values.map((m) => DropdownMenuItem(value: m, child: Text(m.getLocalizedName(context), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _calcMethod = v);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Asr Madhhab
          Text(
            context.tr('setting_asr_method').toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2),
          ),
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
              items: AsrMethodType.values.map((m) => DropdownMenuItem(value: m, child: Text(m.getLocalizedName(context), overflow: TextOverflow.ellipsis))).toList(),
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
              child: Text(context.tr('btn_next')),
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
          Text(
            context.tr('onboard_games_title'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('onboard_games_subtitle'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            decoration: InputDecoration(
              hintText: context.tr('search_games_hint'),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
            ),
            onChanged: (q) => setState(() => _gameSearchQuery = q),
          ),
          const SizedBox(height: 14),

          // Categorized Game List
          Expanded(
            child: ListView(
              children: [
                if (competitiveGames.isNotEmpty) ...[
                  _CategoryHeading(
                    title: context.tr('cat_competitive'),
                    subtitle: context.tr('cat_competitive_sub'),
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
                  _CategoryHeading(
                    title: context.tr('cat_casual'),
                    subtitle: context.tr('cat_casual_sub'),
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
              child: Text(
                selectedCount > 0
                    ? '${context.tr('btn_customize_modes')} ($selectedCount)'
                    : context.tr('select_min_game'),
              ),
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
          Text(
            context.tr('onboard_modes_title'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('onboard_modes_subtitle'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                          GameIconWidget(
                              iconName: game.iconName,
                              size: 28,
                              fallbackColor: game.color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              game.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                          .inputDecorationTheme
                                          .fillColor ??
                                      AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  mode.commitmentType ==
                                          GameCommitmentType.flexible
                                      ? context.tr('mode_flexible')
                                      : '~${mode.estimatedMinutes}${context.tr('min')}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color ??
                                        AppColors.textMuted,
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
              child: Text(context.tr('btn_configure_protection')),
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
          Text(
            context.tr('onboard_protection_title'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('onboard_protection_subtitle'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text(
                                  level.getLocalizedLabel(context),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _selectedTheme.primaryAccent
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    level.getLocalizedBadge(context),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedTheme.primaryAccent),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(level.getLocalizedDesc(context),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
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
              child: Text(context.tr('step_theme_title')),
            ),
          ),
        ],
      ),
    );
  }

  int _themeFilterIndex = 0;

  // STEP 6: Gaming Theme Selection
  Widget _buildThemePage() {
    final filteredThemes = AppGamingTheme.values.where((t) {
      if (_themeFilterIndex == 1) {
        return !t.isLight &&
            t != AppGamingTheme.oled &&
            t != AppGamingTheme.tactical;
      }
      if (_themeFilterIndex == 2) return t.isLight;
      if (_themeFilterIndex == 3) {
        return t == AppGamingTheme.oled || t == AppGamingTheme.tactical;
      }
      return true;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isNarrow = availableWidth < 360;
        final isTablet = availableWidth >= 600;
        final isDesktop = availableWidth >= 800;

        final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
        final cardAspectRatio = isNarrow
            ? 1.18
            : (availableWidth < 420
                ? 1.25
                : (isTablet ? 1.34 : 1.38));

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : (isNarrow ? 14 : 20),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Step Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _selectedTheme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedTheme.primaryAccent
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.palette_rounded,
                          size: 13,
                          color: _selectedTheme.primaryAccent,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isNarrow
                                ? context.tr('theme_badge_step')
                                : context.tr('theme_badge_step_full'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: _selectedTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Heading
                  Text(
                    context.tr('onboard_theme_title'),
                    style: TextStyle(
                      fontSize: isNarrow ? 22 : 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: _selectedTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('onboard_theme_subtitle'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _selectedTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LIVE THEME EXPERIENCE HERO PREVIEW
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.all(isNarrow ? 14 : 18),
                    decoration: BoxDecoration(
                      color: _selectedTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedTheme.primaryAccent
                            .withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedTheme.primaryAccent
                              .withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppLogoWidget(
                              size: isNarrow ? 36 : 42,
                              gamingTheme: _selectedTheme,
                              showGlow: false,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _selectedTheme.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: _selectedTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildThemeModeBadge(
                                          _selectedTheme, isNarrow),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedTheme.tagline,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedTheme.primaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mini Interactive Live Preview Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedTheme.borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _selectedTheme.primaryAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedTheme.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _selectedTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Live color swatches
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildColorDot(_selectedTheme.primaryAccent),
                                  const SizedBox(width: 4),
                                  _buildColorDot(
                                      _selectedTheme.secondaryAccent),
                                  const SizedBox(width: 4),
                                  _buildColorDot(_selectedTheme.surface),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // FILTER CHIPS BAR
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOnboardingFilterChip(
                        context.tr('theme_filter_all'),
                        _themeFilterIndex == 0,
                        () => setState(() => _themeFilterIndex = 0),
                      ),
                      _buildOnboardingFilterChip(
                        context.tr('theme_filter_dark'),
                        _themeFilterIndex == 1,
                        () => setState(() => _themeFilterIndex = 1),
                      ),
                      _buildOnboardingFilterChip(
                        context.tr('theme_filter_light'),
                        _themeFilterIndex == 2,
                        () => setState(() => _themeFilterIndex = 2),
                      ),
                      _buildOnboardingFilterChip(
                        context.tr('theme_filter_special'),
                        _themeFilterIndex == 3,
                        () => setState(() => _themeFilterIndex = 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // RESPONSIVE THEME GRID
                  GridView.builder(
                    itemCount: filteredThemes.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isNarrow ? 8 : 12,
                      mainAxisSpacing: isNarrow ? 8 : 12,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final theme = filteredThemes[index];
                      final isSelected = _selectedTheme == theme;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedTheme = theme),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isNarrow ? 10 : 12),
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
                                      color: theme.primaryAccent
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Bar: Mini Logo + Mode Tag + Radio / Check
                              Row(
                                children: [
                                  AppLogoWidget(
                                    size: 20,
                                    gamingTheme: theme,
                                    showGlow: false,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildMiniModeTag(theme),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.primaryAccent,
                                      size: 16,
                                    )
                                  else
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.borderColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // Color Gradient Ribbon
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryAccent,
                                        theme.secondaryAccent,
                                        theme.surfaceElevated,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Title & Tagline
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? theme.primaryAccent
                                          : theme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    theme.tagline,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.secondaryAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // BOTTOM COMPLETE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _completeOnboarding,
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: Text(
                        context.tr('btn_finish_setup'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTheme.primaryAccent,
                        foregroundColor: _selectedTheme.buttonTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }

  Widget _buildThemeModeBadge(AppGamingTheme theme, bool isNarrow) {
    String label = theme.isLight ? context.tr('theme_badge_light') : context.tr('theme_badge_dark');
    if (theme == AppGamingTheme.oled) label = 'OLED';
    if (theme == AppGamingTheme.tactical) label = 'SPEC-OPS';

    Color bg = theme.isLight
        ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
        : const Color(0xFF8B5CF6).withValues(alpha: 0.15);
    Color textCol = theme.isLight
        ? const Color(0xFF2563EB)
        : const Color(0xFFA78BFA);

    if (theme == AppGamingTheme.oled) {
      bg = Colors.white.withValues(alpha: 0.15);
      textCol = Colors.white;
    } else if (theme == AppGamingTheme.tactical) {
      bg = const Color(0xFF84CC16).withValues(alpha: 0.15);
      textCol = const Color(0xFF84CC16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: textCol,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMiniModeTag(AppGamingTheme theme) {
    String label = theme.isLight ? 'L' : 'D';
    if (theme == AppGamingTheme.oled) label = 'OLED';
    if (theme == AppGamingTheme.tactical) label = 'OPS';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: theme.primaryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
          color: theme.primaryAccent,
        ),
      ),
    );
  }

  Widget _buildOnboardingFilterChip(
      String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedTheme.primaryAccent.withValues(alpha: 0.18)
              : _selectedTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? _selectedTheme.primaryAccent
                : _selectedTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? _selectedTheme.primaryAccent
                : _selectedTheme.textSecondary,
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
      decoration: GlassmorphicDecoration.card(context: context),
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
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.textMuted,
                  ),
                ),
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
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;
    final textMuted =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: primaryColor))
                  : Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: textMuted,
              size: 18,
            ),
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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor =
        Theme.of(context).dividerTheme.color ?? AppColors.surfaceHighlight;
    final textMuted =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: game.isSelected
                ? Color(game.color).withValues(alpha: 0.15)
                : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: game.isSelected ? Color(game.color) : borderColor,
              width: game.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              GameIconWidget(
                  iconName: game.iconName, size: 32, fallbackColor: game.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(
                      '${game.activities.length} ${context.tr('onboard_modes_title')}',
                      style: TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              Icon(
                game.isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: game.isSelected ? Color(game.color) : textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
