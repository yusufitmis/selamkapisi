import 'package:flutter/material.dart';
import 'package:selamkapisi/dashboard/components/main_scaffold.dart';

import 'components/parayer_data.dart';
import 'components/prayer_chart.dart';
import 'components/reminder_button.dart';
import 'components/score_card.dart';
import 'components/smart_suggestions.dart';


class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  int _currentIndex = 2;
  final List<PrayerData> _prayerData = [
    PrayerData(day: 'Pzt', fajr: true, dhuhr: false, asr: true, maghrib: false, isha: true),
    PrayerData(day: 'Sal', fajr: true, dhuhr: true, asr: true, maghrib: false, isha: false),
    PrayerData(day: 'Çar', fajr: false, dhuhr: true, asr: false, maghrib: true, isha: true),
    PrayerData(day: 'Per', fajr: true, dhuhr: true, asr: true, maghrib: true, isha: true),
    PrayerData(day: 'Cum', fajr: true, dhuhr: false, asr: true, maghrib: false, isha: false),
    PrayerData(day: 'Cmt', fajr: false, dhuhr: true, asr: false, maghrib: true, isha: true),
    PrayerData(day: 'Paz', fajr: true, dhuhr: true, asr: true, maghrib: false, isha: false),
  ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreCard(
              score: 78.5,
              averageScore: 65.3,
              onComparePressed: () => _navigateToComparison(),
            ),
            const SizedBox(height: 20),

            // İbadet Takip Başlığı
            Text(
              'HAFTALIK NAMAZ TAKİBİ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber[300],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            PrayerChart(prayerData: _prayerData),
            const SizedBox(height: 20),

            ReminderButton(onPressed: _sendWhatsAppReminder),
            const SizedBox(height: 20),

            // Akıllı Öneri Kartları Başlığı
            Text(
              'AKILLI ÖNERİLER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber[300],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            SmartSuggestions(
              suggestions: _getDemoSuggestions(),
              onSuggestionAction: _handleSuggestionAction,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToComparison() {
    // Karşılaştırma sayfasına git
  }

  void _sendWhatsAppReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kardeşinize namaz hatırlatıcısı gönderildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSuggestionAction(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title aksiyonu alındı'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<Map<String, dynamic>> _getDemoSuggestions() {
    return [
      {
        'icon': Icons.book,
        'color': Colors.blue,
        'title': 'Kur\'an Okuma',
        'description': 'Bugün 10 dakika Kur\'an okumadınız',
        'action': 'Şimdi Oku',
        'points': '+5 puan',
      },
      {
        'icon': Icons.location_on,
        'color': Colors.orange,
        'title': 'İftar Lokasyonu',
        'description': 'En yakın iftar çadırı: 350m uzakta',
        'action': 'Yol Tarifi Al',
        'points': '+3 puan',
      },
      {
        'icon': Icons.night_shelter,
        'color': Colors.purple,
        'title': 'Sabah Namazı',
        'description': 'Yarın sabah namazına kalkarsanız +5 puan',
        'action': 'Hatırlatıcı Kur',
        'points': '+5 puan',
      },
    ];
  }
}