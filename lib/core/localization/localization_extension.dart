import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'app_language.dart';
import 'app_translations.dart';

extension LocalizationContextExtension on BuildContext {
  AppLanguage get appLanguage {
    try {
      final container = ProviderScope.containerOf(this, listen: false);
      return container.read(appLanguageProvider);
    } catch (_) {
      return AppLanguage.english;
    }
  }

  bool get isRtl => appLanguage.isRtl;

  String tr(String key) {
    return AppTranslations.get(key, appLanguage);
  }
}

extension LocalizationWidgetRefExtension on WidgetRef {
  AppLanguage get appLanguage => watch(appLanguageProvider);
  bool get isRtl => appLanguage.isRtl;

  String tr(String key) {
    return AppTranslations.get(key, appLanguage);
  }
}
