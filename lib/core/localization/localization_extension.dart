import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../constants/prayer_constants.dart';
import '../models/prayer_record.dart';
import '../providers/settings_provider.dart';
import 'app_language.dart';
import 'app_translations.dart';

extension LocalizationContextExtension on BuildContext {
  AppLanguage get appLanguage {
    try {
      final container = ProviderScope.containerOf(this, listen: true);
      return container.read(appLanguageProvider);
    } catch (_) {
      return AppLanguage.english;
    }
  }

  bool get isRtl => appLanguage.isRtl;

  String tr(String key) {
    return AppTranslations.get(key, appLanguage);
  }

  String trFormat(String key, Map<String, dynamic> params) {
    return AppTranslations.format(key, appLanguage, params);
  }
}

extension LocalizationWidgetRefExtension on WidgetRef {
  AppLanguage get appLanguage => watch(appLanguageProvider);
  bool get isRtl => appLanguage.isRtl;

  String tr(String key) {
    return AppTranslations.get(key, appLanguage);
  }

  String trFormat(String key, Map<String, dynamic> params) {
    return AppTranslations.format(key, appLanguage, params);
  }
}

extension ProtectionLevelLocalization on ProtectionLevel {
  String getLocalizedLabel(BuildContext context) => context.tr('prot_${name}_label');
  String getLocalizedBadge(BuildContext context) => context.tr('prot_${name}_badge');
  String getLocalizedDesc(BuildContext context) => context.tr('prot_${name}_desc');
}

extension AsrMethodLocalization on AsrMethodType {
  String getLocalizedName(BuildContext context) => context.tr('asr_${name}_name');
  String getLocalizedDesc(BuildContext context) => context.tr('asr_${name}_desc');
}

extension CalculationMethodLocalization on CalculationMethodType {
  String getLocalizedName(BuildContext context) => context.tr('calc_$name');
}

extension ThemeModeOptionLocalization on ThemeModeOption {
  String getLocalizedLabel(BuildContext context) => context.tr('theme_mode_${name}_label');
  String getLocalizedDesc(BuildContext context) => context.tr('theme_mode_${name}_desc');
}

extension PrayerStatusLocalization on PrayerStatus {
  String getLocalizedLabel(BuildContext context) {
    switch (this) {
      case PrayerStatus.onTime:
        return context.tr('status_on_time');
      case PrayerStatus.late:
        return context.tr('status_late');
      case PrayerStatus.missed:
        return context.tr('status_missed');
      case PrayerStatus.notRecorded:
        return context.tr('status_not_recorded');
      case PrayerStatus.upcoming:
        return context.tr('status_upcoming');
      case PrayerStatus.skipped:
        return context.tr('status_skipped');
    }
  }
}

extension RiskLevelLocalization on RiskLevel {
  String getLocalizedLabel(BuildContext context) {
    switch (this) {
      case RiskLevel.low:
        return context.tr('risk_low_label');
      case RiskLevel.medium:
        return context.tr('risk_medium_label');
      case RiskLevel.high:
        return context.tr('risk_high_label');
    }
  }
}

