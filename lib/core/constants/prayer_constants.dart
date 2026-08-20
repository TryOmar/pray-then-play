class PrayerName {
  static const String fajr = 'Fajr';
  static const String sunrise = 'Sunrise';
  static const String dhuhr = 'Dhuhr';
  static const String asr = 'Asr';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isha';

  static const List<String> allPrayers = [fajr, dhuhr, asr, maghrib, isha];
  static const List<String> allTimings = [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

enum CalculationMethodType {
  muslimWorldLeague('Muslim World League'),
  egyptian('Egyptian General Authority'),
  karachi('University of Islamic Sciences, Karachi'),
  ummAlQura('Umm Al-Qura University, Makkah'),
  dubai('Dubai'),
  qatar('Qatar'),
  kuwait('Kuwait'),
  moonsightingCommittee('Moonsighting Committee'),
  singapore('Singapore'),
  turkey('Turkey (Diyanet)'),
  tehran('Tehran'),
  northAmerica('ISNA (North America)');

  const CalculationMethodType(this.displayName);
  final String displayName;
}
