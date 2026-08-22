import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray_then_play/core/localization/translations/ar.dart';
import 'package:pray_then_play/core/localization/translations/de.dart';
import 'package:pray_then_play/core/localization/translations/en.dart';
import 'package:pray_then_play/core/localization/translations/es.dart';
import 'package:pray_then_play/core/localization/translations/fr.dart';
import 'package:pray_then_play/core/localization/translations/id.dart';
import 'package:pray_then_play/core/localization/translations/ms.dart';
import 'package:pray_then_play/core/localization/translations/ru.dart';
import 'package:pray_then_play/core/localization/translations/tr.dart';
import 'package:pray_then_play/core/localization/translations/ur.dart';

void main() {
  test('Audit all translation keys across codebase and all languages', () {
    final allTranslations = <String, Map<String, String>>{
      'en': enTranslations,
      'ar': arTranslations,
      'ur': urTranslations,
      'de': deTranslations,
      'es': esTranslations,
      'fr': frTranslations,
      'id': idTranslations,
      'ms': msTranslations,
      'ru': ruTranslations,
      'tr': trTranslations,
    };

    // 1. Collect all keys used in Dart source files
    final libDir = Directory('lib');
    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('/translations/'));

    final usedKeys = <String>{};
    final regexTr = RegExp(r"(?:context|ref)\.tr\('([a-zA-Z0-9_-]+)'\)");
    final regexTrFormat = RegExp(r"(?:context|ref)\.trFormat\('([a-zA-Z0-9_-]+)'");

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      for (final m in regexTr.allMatches(content)) {
        usedKeys.add(m.group(1)!);
      }
      for (final m in regexTrFormat.allMatches(content)) {
        usedKeys.add(m.group(1)!);
      }
    }

    // Dynamic prayer keys
    for (final p in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'sunrise', 'qiyam']) {
      usedKeys.add('prayer_$p');
    }

    // 2. Check each language against enTranslations and usedKeys
    final enKeys = enTranslations.keys.toSet();
    final allKnownKeys = <String>{...enKeys, ...usedKeys};

    final missingReport = <String, List<String>>{};

    for (final entry in allTranslations.entries) {
      final lang = entry.key;
      final map = entry.value;
      final missing = <String>[];

      for (final key in allKnownKeys) {
        if (!map.containsKey(key) || map[key]!.trim().isEmpty) {
          missing.add(key);
        }
      }

      if (missing.isNotEmpty) {
        missingReport[lang] = missing;
      }
    }

    expect(missingReport.isEmpty, isTrue,
        reason: 'Some languages are missing translation keys: $missingReport');
  });
}
