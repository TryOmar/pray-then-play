import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Pray Then Play';
  static const String tagline = 'Stay on time. Play with peace of mind.';
  static const String version = '2.0.0';

  // Storage keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyAsrMethod = 'asr_method';
  static const String keyProtectionLevel = 'protection_level';
  static const String keyGamingTheme = 'gaming_theme_v2';
  static const String keyThemeMode = 'theme_mode_v1';
  static const String keyGamerProfile = 'gamer_profile';
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyCityName = 'city_name';
  static const String keyCountryName = 'country_name';
  static const String keyConfiguredGames = 'configured_games_v2';
  static const String keyGameSessions = 'game_session_history_v1';
  static const String keyPrayerLog = 'prayer_log';
  static const String keyJumuahMode = 'jumuah_mode';
  static const String keyFajrMode = 'fajr_mode';
  static const String keyInMatch = 'in_match';
  static const String keyMatchStartTime = 'match_start_time';
  static const String keyIs24HourFormat = 'time_format_is_24h';

  // Notification channels
  static const String notificationChannelId = 'pray_then_play_prayers';
  static const String notificationChannelName = 'Prayer Reminders';
  static const String notificationChannelDesc = 'Smart prayer reminders for gamers';
}

enum ThemeModeOption {
  manual('Manual Theme', 'Always use chosen theme'),
  system('System Dynamic', 'Follow device light/dark mode'),
  sunCycle('Sunrise / Sunset', 'Dawn by day • Midnight by night');

  const ThemeModeOption(this.label, this.description);
  final String label;
  final String description;
}

enum ProtectionLevel {
  relaxed('Relaxed', '5 min buffer', 'Small safety margin. You have more usable gaming time.', 5),
  balanced('Balanced', '10 min buffer (Recommended)', 'Standard safety margin before prayer.', 10),
  strict('Strict', '15 min buffer', 'Large safety margin. Never get trapped in overtime.', 15);

  const ProtectionLevel(this.label, this.badge, this.description, this.bufferMinutes);
  final String label;
  final String badge;
  final String description;
  final int bufferMinutes;
}

enum AsrMethodType {
  standard('Standard (Shafi\'i, Maliki, Hanbali)', 'Shadow length equals object length (1x)'),
  hanafi('Hanafi', 'Shadow length equals twice object length (2x)');

  const AsrMethodType(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum GamerProfile {
  casual('Casual Gamer', 'I play for fun and value flexible breaks'),
  competitive('Competitive Gamer', 'I play ranked and care about climbing without missing Salah'),
  hardcore('Dedicated Gamer', 'Long sessions, need strict prayer window management');

  const GamerProfile(this.label, this.description);
  final String label;
  final String description;
}

enum GamingStatus {
  safe('Safe to play', Color(0xFF00FF88)),
  caution('Use caution', Color(0xFFFFB800)),
  dontQueue('Not recommended', Color(0xFFFF3D5A)),
  prayerTime('Prayer time', Color(0xFFFF3D5A));

  const GamingStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum RiskLevel {
  low('Recommended now', 'Fits comfortably before prayer', Color(0xFF00FF88)),
  medium('Use caution', 'May enter prayer time if match goes into overtime', Color(0xFFFFB800)),
  high('Not recommended right now', 'Match duration exceeds available time', Color(0xFFFF3D5A));

  const RiskLevel(this.label, this.description, this.color);
  final String label;
  final String description;
  final Color color;
}
