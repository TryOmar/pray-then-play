import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../constants/app_constants.dart';
import '../constants/prayer_constants.dart';
import '../services/storage_service.dart';

// Gaming Theme State
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
