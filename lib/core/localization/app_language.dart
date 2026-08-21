import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English', 'English', '🇬🇧', isRtl: false),
  arabic('ar', 'Arabic', 'العربية', '🇸🇦', isRtl: true),
  turkish('tr', 'Turkish', 'Türkçe', '🇹🇷', isRtl: false),
  indonesian('id', 'Indonesian', 'Bahasa Indonesia', '🇮🇩', isRtl: false),
  french('fr', 'French', 'Français', '🇫🇷', isRtl: false),
  german('de', 'German', 'Deutsch', '🇩🇪', isRtl: false),
  urdu('ur', 'Urdu', 'اردو', '🇵🇰', isRtl: true),
  malay('ms', 'Malay', 'Bahasa Melayu', '🇲🇾', isRtl: false),
  russian('ru', 'Russian', 'Русский', '🇷🇺', isRtl: false),
  spanish('es', 'Spanish', 'Español', '🇪🇸', isRtl: false);

  const AppLanguage(
    this.code,
    this.englishName,
    this.nativeName,
    this.flag, {
    required this.isRtl,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final String flag;
  final bool isRtl;

  Locale get locale => Locale(code);
  TextDirection get direction => isRtl ? TextDirection.rtl : TextDirection.ltr;

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }
}
