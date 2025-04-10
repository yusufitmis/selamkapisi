import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:selamkapisi/dashboard/components/main_scaffold.dart';
import 'package:selamkapisi/fatwa/preacher_tab/preachers_tab.dart';
import '../google_ads.dart';
import 'fatwa_tab/fatwa_tab.dart';

class FatwaPage extends StatefulWidget {
  const FatwaPage({super.key});

  @override
  State<FatwaPage> createState() => _FatwaPageState();
}

class _FatwaPageState extends State<FatwaPage> {
  final _currentIndex = 1;
  int _selectedTab = 0;
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() {}),
        ),
      ],
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ?  FatwaTab()
                :  PreachersTab(),
          ),
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
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 48,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Fetva Sor'),
                ),
              ),
              ButtonSegment(
                value: 1,
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Vaizler'),
                ),
              ),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() => _selectedTab = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              selectedBackgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              selectedForegroundColor: Colors.black,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}