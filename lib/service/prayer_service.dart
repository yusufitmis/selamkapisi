import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../coach/components/parayer_data.dart';

class PrayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<PrayerData>> getWeeklyPrayerData() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    DocumentSnapshot doc = await _firestore
        .collection('prayerRecords')
        .doc(user.uid)
        .collection('weekly')
        .doc('current')
        .get();

    if (doc.exists) {
      Map data = doc.data() as Map;
      return [
        PrayerData.fromMap(data['monday']),
        PrayerData.fromMap(data['tuesday']),
        PrayerData.fromMap(data['wednesday']),
        PrayerData.fromMap(data['thursday']),
        PrayerData.fromMap(data['friday']),
        PrayerData.fromMap(data['saturday']),
        PrayerData.fromMap(data['sunday']),
      ];
    }
    return _getDefaultPrayerData();
  }

  Stream<List<PrayerData>> getPrayerDataStream() {
    log('PrayerService: getPrayerDataStream çağrıldı');

    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        log('Kullanıcı giriş yapmamış, boş veri dönülecek');
        return Stream.value(_getDefaultWeek());
      }

      log('Firestore verisi çekilecek. Kullanıcı ID: ${user.uid}');

      return _firestore
          .collection('prayerRecords')
          .doc(user.uid)
          .collection('weekly')
          .doc('current')
          .snapshots()
          .map(_parseData)
          .handleError((error) {
        log('Firestore hatası: $error', error: error, stackTrace: StackTrace.current);
        return _getDefaultWeek();
      });
    });
  }

  List<PrayerData> _parseData(DocumentSnapshot snapshot) {
    log('Firestore dokümanı alındı. Exists: ${snapshot.exists}');

    if (!snapshot.exists) {
      log('Doküman bulunamadı, varsayılan veri dönülecek');
      return _getDefaultWeek();
    }

    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    log('Ham Firestore verisi: ${data.toString()}');

    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    final parsedData = days.map((day) {
      final dayData = data[day] as Map<String, dynamic>? ?? {};
      log('$day günü verisi: $dayData');

      return PrayerData(
        day: day,
        fajr: dayData['fajr'] ?? false,
        dhuhr: dayData['dhuhr'] ?? false,
        asr: dayData['asr'] ?? false,
        maghrib: dayData['maghrib'] ?? false,
        isha: dayData['isha'] ?? false,
      );
    }).toList();

    log('Parse edilen son veri: ${parsedData.map((e) => e.toMap()).toString()}');
    return parsedData;
  }

  List<PrayerData> _getDefaultWeek() {
    log('Varsayılan haftalık veri oluşturuluyor');
    return const [
      PrayerData(day: 'mon', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'tue', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'wed', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'thu', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'fri', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'sat', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'sun', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
    ];
  }



  List<PrayerData> _getDefaultPrayerData() {
    return const [
      PrayerData(day: 'mon', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'tue', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'wed', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'thu', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'fri', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'sat', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
      PrayerData(day: 'sun', fajr: false, dhuhr: false, asr: false, maghrib: false, isha: false),
    ];
  }

  Future<void> updatePrayerRecord(String day, String prayerName, bool isCompleted) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('prayerRecords')
        .doc(user.uid)
        .collection('weekly')
        .doc('current')
        .update({
      '$day.$prayerName': isCompleted
    });
  }

  Future<void> updatePrayer(String day, String prayer, bool isCompleted) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('prayerRecords')
        .doc(user.uid)
        .collection('weekly')
        .doc('current');

    // Check if document exists, if not create it with default values
    final doc = await docRef.get();
    if (!doc.exists) {
      await _initializeWeeklyPrayerDocument(user.uid);
    }

    // Now update the document
    await docRef.update({
      '$day.$prayer': isCompleted,
      '$day.day': day,
    });
  }

  Future<void> _initializeWeeklyPrayerDocument(String userId) async {
    await _firestore
        .collection('prayerRecords')
        .doc(userId)
        .collection('weekly')
        .doc('current')
        .set({
      'mon': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'mon'},
      'tue': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'tue'},
      'wed': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'wed'},
      'thu': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'thu'},
      'fri': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'fri'},
      'sat': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'sat'},
      'sun': {'fajr': false, 'dhuhr': false, 'asr': false, 'maghrib': false, 'isha': false, 'day': 'sun'},
    });
  }

  Future<void> resetWeeklyData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final lastReset = prefs.getString('lastPrayerResetDate');

      // Only reset on Mondays and if not already reset this week
      if (now.weekday == DateTime.monday &&
          (lastReset == null || _getLastMonday(now).isAfter(DateTime.parse(lastReset)))) {

        await _initializeWeeklyPrayerDocument(userId);
        await prefs.setString('lastPrayerResetDate', _getLastMonday(now).toString());
      }
    } catch (e) {
      log('Reset error: $e');
      rethrow;
    }
  }

  DateTime _getLastMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }



  // PrayerService'e eklenmesi gereken yeni metodlar
  bool _isPrayerTimeValid(String prayer, DateTime now) {
    final hour = now.hour;
    final minute = now.minute;

    switch (prayer) {
      case 'fajr':
        return (hour == 5 && minute >= 30) ||
            (hour > 5 && hour < 12) ||
            (hour == 12 && minute <= 59);
      case 'dhuhr':
        return (hour == 13 && minute >= 0) ||
            (hour > 13 && hour < 16) ||
            (hour == 16 && minute <= 29);
      case 'asr':
        return (hour == 16 && minute >= 30) ||
            (hour > 16 && hour < 19) ||
            (hour == 19 && minute <= 29);
      case 'maghrib':
        return (hour == 19 && minute >= 30) ||
            (hour > 19 && hour < 20) ||
            (hour == 20 && minute <= 59);
      case 'isha':
        return (hour == 21 && minute >= 0) ||
            (hour > 21) ||
            (hour < 5) ||
            (hour == 5 && minute <= 29);
      default:
        return false;
    }
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    // DateTime.now().weekday: 1=Pazartesi, 7=Pazar
    // Bizim listemiz: 0=Pazartesi, 6=Pazar
    final todayIndex = (now.weekday - 1) % 7;

    return day == days[todayIndex];
  }

  Future<void> updatePrayerWithValidation(String day, String prayer) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    // 1. Gün kontrolü
    if (!_isToday(day)) {
      throw 'Sadece bugünün namazlarını işaretleyebilirsiniz';
    }

    // 2. Vakit kontrolü
    if (!_isPrayerTimeValid(prayer, now)) {
      throw 'Bu namazı işaretlemek için uygun vakit değil';
    }

    // 3. Güncelleme işlemi
    await _firestore
        .collection('prayerRecords')
        .doc(user.uid)
        .collection('weekly')
        .doc('current')
        .update({
      '$day.$prayer': true,
      '$day.day': day,
    });
  }


}