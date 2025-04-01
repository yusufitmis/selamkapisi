import 'package:flutter/material.dart';

class VerseUtils {
  static void showRandomVerse(BuildContext context) {
    const verses = [
      {
        'text': "Allah, kendisine karşı gelmekten sakınanlar ile beraberdir. (Bakara 194)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "Sabret, şüphesiz Allah iyilik yapanların mükafatını zayi etmez. (Hud 115)",
        'source': "Kur'an-ı Kerim"
      },
      {
        'text': "İman etmedikçe cennete giremezsiniz, birbirinizi sevmedikçe de iman etmiş olamazsınız.",
        'source': "Hadis-i Şerif"
      },
    ];

    final randomVerse = verses[DateTime.now().second % verses.length];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          randomVerse['source'] as String,
          style: TextStyle(color: Colors.amber[300]),
        ),
        content: Text(
          randomVerse['text'] as String,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Share functionality
              Navigator.pop(context);
            },
            child: Text('Paylaş', style: TextStyle(color: Colors.amber[300])),
          ),
        ],
      ),
    );
  }
}