import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:selamkapisi/dashboard/components/daily_quote_banner.dart';
import 'dashboard/components/main_scaffold.dart';
import 'dashboard/components/personel_info_panel.dart';
import 'dashboard/components/preacher_section.dart';
import 'dashboard/components/qucik_access_buttons.dart';
import 'google_ads.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final GoogleAds googleAds = GoogleAds();
  @override
  void initState() {
    super.initState(); // Bunu unutma!
    googleAds.loadInterstitialAd();
    googleAds.loadBannerAd(adLoaded: () {
      setState(() {

      });
    },);
  }

  @override
  void dispose() {
    googleAds.bannerAd?.dispose();
    googleAds.interstitialAd?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _currentIndex,

      body: SingleChildScrollView(
        child: Column(
          children: [
            DailyQuoteBanner(),
            PersonalInfoPanel(
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            QuickAccessButtons(googleAds: googleAds),
            PreachersSection(googleAds: googleAds),
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
                    color: Colors.grey, // Koyu altın rengi border
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
  }


}