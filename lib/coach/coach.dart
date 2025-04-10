import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/components/main_scaffold.dart';
import '../google_ads.dart';
import '../models/user_model.dart';
import '../service/prayer_service.dart';
import '../service/user_service.dart';
import 'components/parayer_data.dart';
import 'components/score_card.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  // Colors

  final Color _secondaryColor = const Color(0xFFD4AF37);
  final Color _accentColor = const Color(0xFF64B5F6);
  final Color _textColor = Colors.white;
  final Color _cardColor = const Color(0xFF1E1E1E);

  // Services
  late UserService _userService;
  late PrayerService _prayerService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constants
  final DateTime _initialDate = DateTime(2025, 3, 31); // 31.03.2025 Monday
  final int _cycleLength = 6; // 6-week cycle
  final int _resetInterval = 28; // Reset every 28 days (4 weeks)

  // State
  late double _currentScore;
  late double _totalScore = 0;
  final GoogleAds googleAds = GoogleAds();


  @override
  void dispose() {
    googleAds.bannerAd?.dispose();
    googleAds.interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _prayerService = PrayerService();
    _currentScore = 0;
    _initializeAppData();
    googleAds.loadInterstitialAd();
    googleAds.loadBannerAd(adLoaded: () {
      setState(() {

      });
    },);
  }

  int _calculateCurrentWeek() {
    final now = DateTime.now();
    final daysPassed = now.difference(_initialDate).inDays;
    return (daysPassed ~/ 7) % _cycleLength; // Returns 0-5
  }

  bool _shouldResetData() {
    final now = DateTime.now();
    return now.difference(_initialDate).inDays % _resetInterval == 0;
  }

  Future<void> _initializeAppData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalScore = prefs.getDouble('totalScore') ?? 0;

    if (_shouldResetData()) {
      await _resetAllData();
    }

    if (mounted) setState(() {});
  }

  Future<void> _resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;

    if (user != null) {
      // 1. Mevcut puanı hesapla
      final userModel = await _userService.getUserData();
      _currentScore = await _calculateScore(userModel);

      // 2. Toplam puana ekle
      _totalScore += _currentScore;

      // 3. Firestore'a kaydet
      await _userService.updateProfilePuan(_totalScore);
      debugPrint('🔥 Yeni profilePuan: $_totalScore');

      // 4. Diğer verileri sıfırla
      await _userService.resetUserStats(user.uid);
      await _prayerService.resetWeeklyData(user.uid);
      await prefs.setDouble('totalScore', _totalScore);


      if (mounted) setState(() {});
    }
  }

  Future<double> _calculateScore(UserModel user) async {
    if (user.uid.isEmpty) return 0;

    double score = (user.prayerCount * 1 +
        user.quranPages * 2 +
        user.charityAmount * 0.5 +
        user.socialPoints * 0.1);

    return score.clamp(0, 100).toDouble();
  }

  // Prayer tracking methods (unchanged from your original)
  Future<void> _updatePrayerStatus(String day, String prayer) async {
    try {
      final now = DateTime.now();

      // 1. Bugün mü kontrolü
      if (day != _getCurrentDay()) {
        throw 'Sadece bugünün namazlarını işaretleyebilirsiniz';
      }

      // 2. Vakit kontrolü
      if (!_isValidPrayerTime(prayer)) {
        throw 'Bu namazı işaretlemek için uygun vakit değil';
      }

      // 3. Reklam göster
      await googleAds.interstitialAd?.show();

      // 3. Firestore güncelleme
      await _prayerService.updatePrayer(day, prayer, true);
      await _userService.incrementPrayerCount(1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getPrayerName(prayer)} namazı kaydedildi! +1 puan'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool _isValidPrayerTime(String prayer) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    switch (prayer) {
      case 'fajr':
      // Sabah: 04:30 - 06:30
        return (hour == 4 && minute >= 30) ||
            (hour == 5) ||
            (hour == 6 && minute <= 30);
      case 'dhuhr':
      // Öğle: 12:00 - 13:30
        return (hour == 12 && minute >= 0) ||
            (hour == 13 && minute <= 30);
      case 'asr':
      // İkindi: 15:00 - 17:00
        return (hour == 15 && minute >= 0) ||
            (hour == 16) ||
            (hour == 17 && minute <= 0);
      case 'maghrib':
      // Akşam: 18:30 - 20:30
        return (hour == 18 && minute >= 30) ||
            (hour == 19) ||
            (hour == 20 && minute <= 30);
      case 'isha':
      // Yatsı: 20:00 - 23:59
        return (hour >= 20 && hour <= 23) ||
            (hour == 0 && minute <= 0);
      default:
        return false;
    }
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayIndex = (now.weekday - 1) % 7;
    return day == days[todayIndex];
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return days[(now.weekday - 1) % 7];
  }

  String _getPrayerName(String field) {
    switch (field) {
      case 'fajr': return 'Sabah';
      case 'dhuhr': return 'Öğle';
      case 'asr': return 'İkindi';
      case 'maghrib': return 'Akşam';
      case 'isha': return 'Yatsı';
      default: return '';
    }
  }

  Icon _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'fajr': return Icon(Icons.wb_sunny, color: Colors.green);
      case 'dhuhr': return Icon(Icons.sunny, color: _accentColor);
      case 'asr': return Icon(Icons.brightness_4, color: Colors.orange);
      case 'maghrib': return Icon(Icons.nights_stay, color: Colors.purple);
      case 'isha': return Icon(Icons.dark_mode, color: Colors.deepPurple);
      default: return const Icon(Icons.error);
    }
  }

  Widget _buildPrayerChart(List<PrayerData> prayerData) {
    final fullWeekData = _ensureFullWeekData(prayerData);

    return Card(
      color: _cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(labelStyle: TextStyle(color: _textColor)),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 5,
                  interval: 1,
                  labelStyle: TextStyle(color: _textColor),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<PrayerData, String>(
                    dataSource: fullWeekData,
                    xValueMapper: (data, _) => _getDayName(data.day),
                    yValueMapper: (data, _) => data.completedPrayers,
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: _textColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildPrayerLegends(),
          ],
        ),
      ),
    );
  }

  List<PrayerData> _ensureFullWeekData(List<PrayerData> prayerData) {
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final fullData = <PrayerData>[];

    for (final day in days) {
      final existingData = prayerData.firstWhere(
            (data) => data.day == day,
        orElse: () => PrayerData(
          day: day,
          fajr: false,
          dhuhr: false,
          asr: false,
          maghrib: false,
          isha: false,
        ),
      );
      fullData.add(existingData);
    }

    return fullData;
  }

  String _getDayName(String day) {
    switch (day) {
      case 'mon': return 'Pzt';
      case 'tue': return 'Sal';
      case 'wed': return 'Çar';
      case 'thu': return 'Per';
      case 'fri': return 'Cum';
      case 'sat': return 'Cmt';
      case 'sun': return 'Paz';
      default: return day;
    }
  }

  Widget _buildPrayerLegends() {
    final legends = [
      {'icon': Icons.wb_sunny, 'text': 'Sabah', 'color': Colors.green},
      {'icon': Icons.sunny, 'text': 'Öğle', 'color': Colors.blue},
      {'icon': Icons.brightness_4, 'text': 'İkindi', 'color': Colors.orange},
      {'icon': Icons.nights_stay, 'text': 'Akşam', 'color': Colors.purple},
      {'icon': Icons.dark_mode, 'text': 'Yatsı', 'color': Colors.deepPurple},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: legends.map((legend) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(legend['icon'] as IconData, color: legend['color'] as Color, size: 16),
          const SizedBox(width: 4),
          Text(legend['text'] as String, style: TextStyle(color: _textColor, fontSize: 12)),
        ],
      )).toList(),
    );
  }

  Widget _buildPrayerGrid(List<PrayerData> prayerData) {
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final currentDay = _getCurrentDay();

    return Card(
      color: _cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade800),
          columnWidths: const {0: FixedColumnWidth(50)},
          children: [
            TableRow(
              decoration: BoxDecoration(color: _secondaryColor.withAlpha((255 * 0.2).round())),
              children: [
                const SizedBox.shrink(),
                ...prayers.map((p) => Center(child: _getPrayerIcon(p))),
              ],
            ),
            ...days.asMap().entries.map((dayEntry) {
              final dayIndex = dayEntry.key;
              final dayData = prayerData.firstWhere(
                    (data) => data.day == days[dayIndex],
                orElse: () => PrayerData(
                  day: days[dayIndex],
                  fajr: false,
                  dhuhr: false,
                  asr: false,
                  maghrib: false,
                  isha: false,
                ),
              );
              final isToday = dayData.day == currentDay;

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      dayNames[dayIndex],
                      style: TextStyle(
                        color: isToday ? _secondaryColor : _textColor,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...prayers.map((prayer) {
                    final isCompleted = dayData.toMap()[prayer] == true;
                    final canMark = isToday &&
                        !isCompleted &&
                        _isValidPrayerTime(prayer);

                    return InkWell(
                      onTap: canMark
                          ? () async {
                        // Reklam göster ve sonra namazı işaretle
                        try {
                          await googleAds.interstitialAd?.show();
                          await _updatePrayerStatus(dayData.day, prayer);
                        } catch (e) {
                          debugPrint('Error showing ad: $e');
                          // Reklam gösterilemezse direkt namazı işaretle
                          await _updatePrayerStatus(dayData.day, prayer);
                        }
                      }
                          : null,
                      child: Container(
                        color: isCompleted
                            ? _secondaryColor.withAlpha((255 * 0.3).round())
                            : isToday
                            ? canMark
                            ? _cardColor.withAlpha((255 * 0.5).round())
                            : Colors.grey.withAlpha((255 * 0.3).round())
                            : Colors.transparent,
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : isToday
                              ? canMark
                              ? Icons.add
                              : Icons.lock_clock
                              : Icons.block,
                          color: isCompleted
                              ? _secondaryColor
                              : isToday
                              ? canMark
                              ? _textColor.withAlpha((255 * 0.8).round())
                              : Colors.grey
                              : Colors.grey,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<UserModel>.value(
          value: _userService.getUserStream(),
          initialData: UserModel(uid: ''),
        ),
        StreamProvider<List<PrayerData>>.value(
          value: _prayerService.getPrayerDataStream(),
          initialData: const [],
        ),
      ],
      child: Consumer2<UserModel?, List<PrayerData>?>(builder: (context, user, prayerData, child) {
        if (user == null || prayerData == null) {
          return Center(child: CircularProgressIndicator(color: _secondaryColor));
        }

        return FutureBuilder<double>(
          future: _calculateScore(user),
          builder: (context, snapshot) {
            final score = snapshot.data ?? 0;
            final averageScore = 65.3;
            final currentWeek = _calculateCurrentWeek() + 1;
            final weeksLeft = _cycleLength - currentWeek;

            return MainScaffold(
              currentIndex: 2,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreCard(
                      score: score,
                      averageScore: averageScore,
                      currentWeek: currentWeek,
                      weeksLeft: weeksLeft,
                      onComparePressed: () => Navigator.pushNamed(context, '/comparison'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'HAFTALIK NAMAZ TAKİBİ',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPrayerChart(prayerData),
                    const SizedBox(height: 20),
                    _buildPrayerGrid(prayerData),
                    const SizedBox(height: 20),
                    Card(
                      color: _cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: _secondaryColor, size: 30),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Toplam Puan',
                                  style: TextStyle(color: _textColor.withAlpha((255 * 0.8).round())),
                                ),
                                Text(
                                  (_totalScore + score).toStringAsFixed(0),
                                  style: TextStyle(
                                    color: _textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Banner Ad - Fixed at bottom
                    // Banner Ad - Modern görünümlü, altın renkli border ile
                    // Banner Ad - Altın rengi arka plan, 3D etkisi ve modern görünüm
                    if (googleAds.bannerAd != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade300, Colors.amber.shade700], // Altın renkli degrade arka plan
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16), // Yuvarlatılmış köşeler
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4), // Gölgeli 3D etkisi
                            ),
                          ],
                          border: Border.all(
                            color: Colors.amber.shade900, // Koyu altın rengi border
                            width: 3, // Daha belirgin border
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12), // Padding değerini arttırdım
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 15), // Üst ve alt margin
                        child: SizedBox(
                          width: googleAds.bannerAd!.size.width.toDouble(),
                          height: googleAds.bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: googleAds.bannerAd!),
                        ),
                      ),


                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }


}