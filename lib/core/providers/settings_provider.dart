import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../constants/app_constants.dart';
import '../constants/prayer_constants.dart';
import '../services/storage_service.dart';

// System brightness listener state
final systemBrightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);

// Theme Mode Option (Manual, System, Sunrise/Sunset)
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeModeOption>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeModeNotifier() : super(StorageService.themeMode);

  void setMode(ThemeModeOption mode) {
    state = mode;
    StorageService.setThemeMode(mode);
  }
}

// Gaming Theme State (Manual Choice)
final gamingThemeProvider =
    StateNotifierProvider<GamingThemeNotifier, AppGamingTheme>((ref) {
  return GamingThemeNotifier();
});

class GamingThemeNotifier extends StateNotifier<AppGamingTheme> {
  GamingThemeNotifier() : super(StorageService.gamingTheme);

  void setTheme(AppGamingTheme theme) {
    state = theme;
    StorageService.setGamingTheme(theme);
  }
}

// Effective active theme resolving Manual, System Dynamic, or Sunrise/Sunset cycle
final effectiveThemeProvider = Provider<AppGamingTheme>((ref) {
  final mode = ref.watch(themeModeProvider);
  final manualTheme = ref.watch(gamingThemeProvider);
  final systemBrightness = ref.watch(systemBrightnessProvider);

  switch (mode) {
    case ThemeModeOption.manual:
      return manualTheme;

    case ThemeModeOption.system:
      if (systemBrightness == Brightness.light) {
        // If user already picked a light theme, use that; otherwise signature Dawn
        return manualTheme.isLight ? manualTheme : AppGamingTheme.dawn;
      } else {
        // If user picked a dark theme, use that; otherwise signature Midnight
        return !manualTheme.isLight ? manualTheme : AppGamingTheme.midnight;
      }

    case ThemeModeOption.sunCycle:
      final hour = DateTime.now().hour;
      // Daytime (06:00 to 18:30) -> Signature Dawn; Night -> Signature Midnight
      final isDaytime = hour >= 6 && hour < 19;
      return isDaytime ? AppGamingTheme.dawn : AppGamingTheme.midnight;
  }
});

// Calculation Method
final calculationMethodProvider =
    StateNotifierProvider<CalculationMethodNotifier, CalculationMethodType>((ref) {
  return CalculationMethodNotifier();
});

class CalculationMethodNotifier extends StateNotifier<CalculationMethodType> {
  CalculationMethodNotifier() : super(StorageService.calculationMethod);

  void setMethod(CalculationMethodType method) {
    state = method;
    StorageService.setCalculationMethod(method);
  }
}

// Asr Method (Standard vs. Hanafi)
final asrMethodProvider =
    StateNotifierProvider<AsrMethodNotifier, AsrMethodType>((ref) {
  return AsrMethodNotifier();
});

class AsrMethodNotifier extends StateNotifier<AsrMethodType> {
  AsrMethodNotifier() : super(StorageService.asrMethod);

  void setMethod(AsrMethodType method) {
    state = method;
    StorageService.setAsrMethod(method);
  }
}

// Protection Level
final protectionLevelProvider =
    StateNotifierProvider<ProtectionLevelNotifier, ProtectionLevel>((ref) {
  return ProtectionLevelNotifier();
});

class ProtectionLevelNotifier extends StateNotifier<ProtectionLevel> {
  ProtectionLevelNotifier() : super(StorageService.protectionLevel);

  void setLevel(ProtectionLevel level) {
    state = level;
    StorageService.setProtectionLevel(level);
  }
}

// Safety Buffer in Minutes (Derived from protection level)
final safetyBufferMinutesProvider = Provider<int>((ref) {
  final level = ref.watch(protectionLevelProvider);
  return level.bufferMinutes;
});

// Jumu'ah Mode
final jumuahModeProvider =
    StateNotifierProvider<JumuahModeNotifier, bool>((ref) {
  return JumuahModeNotifier();
});

class JumuahModeNotifier extends StateNotifier<bool> {
  JumuahModeNotifier() : super(StorageService.jumuahMode);

  void toggle() {
    state = !state;
    StorageService.setJumuahMode(state);
  }
}

// Fajr Mode
final fajrModeProvider = StateNotifierProvider<FajrModeNotifier, bool>((ref) {
  return FajrModeNotifier();
});

class FajrModeNotifier extends StateNotifier<bool> {
  FajrModeNotifier() : super(StorageService.fajrMode);

  void toggle() {
    state = !state;
    StorageService.setFajrMode(state);
  }
}

// Time Format Preference (12-Hour AM/PM vs 24-Hour)
final timeFormatIs24HourProvider =
    StateNotifierProvider<TimeFormatNotifier, bool>((ref) {
  return TimeFormatNotifier();
});

class TimeFormatNotifier extends StateNotifier<bool> {
  TimeFormatNotifier() : super(StorageService.is24HourFormat);

  void set24Hour(bool is24Hour) {
    state = is24Hour;
    StorageService.setIs24HourFormat(is24Hour);
  }

  void toggle() {
    set24Hour(!state);
  }
}

