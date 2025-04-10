import 'package:flutter/material.dart';

import '../../google_ads.dart';
import '../utils/verse_utils.dart';

class QuickAccessButtons extends StatelessWidget {
  final GoogleAds googleAds;
  QuickAccessButtons({super.key, required this.googleAds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.5).round()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HIZLI ERİŞİM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[300],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickAccessButton(
                icon: Icons.chat,
                label: 'Fetva Soralım',
                color: Colors.green,
                onTap: () {
                  googleAds.interstitialAd?.show();
                  Navigator.pushReplacementNamed(context, '/fatwa');
                }
              ),
              _buildQuickAccessButton(
                icon: Icons.book,
                label: 'İman Tazele',
                color: Colors.blue,
                onTap: () {
                  googleAds.interstitialAd?.show();
                  VerseUtils.showRandomVerse(context);
                }
              ),
              _buildQuickAccessButton(
                icon: Icons.emoji_events,
                label: 'Görevlerim',
                color: Colors.purple,
                onTap: () {
                  googleAds.interstitialAd?.show();
                  Navigator.pushReplacementNamed(context, '/coach');
                }
              ),
              _buildQuickAccessButton(
                icon: Icons.person,
                label: 'Profil',
                color: Colors.orange,
                onTap: () {
                  googleAds.interstitialAd?.show();
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha((255 * 0.2).round()),
              color.withAlpha((255 * 0.1).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha((255 * 0.3).round())),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}