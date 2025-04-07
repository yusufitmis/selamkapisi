class PrayerData {
  final String day;
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;

  const PrayerData({
    required this.day,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerData.fromMap(Map<String, dynamic> map) {
    return PrayerData(
      day: map['day'] ?? '',
      fajr: map['fajr'] ?? false,
      dhuhr: map['dhuhr'] ?? false,
      asr: map['asr'] ?? false,
      maghrib: map['maghrib'] ?? false,
      isha: map['isha'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  int get completedPrayers {
    return [fajr, dhuhr, asr, maghrib, isha].where((e) => e).length;
  }
}