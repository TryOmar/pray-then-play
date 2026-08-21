import 'app_language.dart';
import 'translations/ar.dart';
import 'translations/de.dart';
import 'translations/en.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/id.dart';
import 'translations/ms.dart';
import 'translations/ru.dart';
import 'translations/tr.dart';
import 'translations/ur.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'en': enTranslations,
    'ar': arTranslations,
    'tr': trTranslations,
    'id': idTranslations,
    'ur': urTranslations,
    'fr': frTranslations,
    'de': deTranslations,
    'ms': msTranslations,
    'ru': ruTranslations,
    'es': esTranslations,
  };

  /// Get translation for [key] in [language]. Falls back to English if missing.
  static String get(String key, AppLanguage language) {
    final langCode = language.code;
    final map = _translations[langCode] ?? _translations['en']!;
    if (map.containsKey(key)) {
      return map[key]!;
    }
    // Fallback to English
    return _translations['en']?[key] ?? key;
  }

  /// Format translation string containing {param} placeholders
  static String format(String key, AppLanguage language, Map<String, dynamic> params) {
    var text = get(key, language);
    params.forEach((paramKey, paramValue) {
      text = text.replaceAll('{$paramKey}', paramValue.toString());
    });
    return text;
  }
}
