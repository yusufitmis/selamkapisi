import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selamkapisi/fatwa/preacher_tab/preacher_list.dart';
import '../../google_ads.dart';
import 'add_preacher_dialog.dart';

class PreachersTab extends StatefulWidget {


  const PreachersTab({super.key});

  @override
  State<PreachersTab> createState() => _PreachersTabState();
}

class _PreachersTabState extends State<PreachersTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Color scheme
  final Color _primaryColor = const Color(0xFF121212); // Black
  final Color _secondaryColor = const Color(0xFFD4AF37); // Gold
  final Color _backgroundColor = const Color(0xFFE6F2FF); // Açık mavi arka plan

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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Tarihi Din Alimleri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        iconTheme: IconThemeData(
          color: _secondaryColor,
          size: 30,
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'İslam Alimleri ve Vaizler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PreachersList(googleAds: googleAds),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _auth.currentUser?.email == 'yusufitms@gmail.com'
          ? FloatingActionButton(
        onPressed: () => _showAddPreacherDialog(context),
        backgroundColor: _secondaryColor,
        tooltip: 'Yeni Vaiz Ekle',
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.add,
          color: _primaryColor,
          size: 32,
        ),
      )
          : null,
    );
  }

  void _showAddPreacherDialog(BuildContext context) {
    // Reklam göster (eğer varsa)
      googleAds?.interstitialAd?.show().then((_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AddPreacherDialog(),
          barrierDismissible: false,
        );
      }
    }).catchError((error) {
      // Reklam gösterilemezse direkt dialogu aç
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AddPreacherDialog(),
          barrierDismissible: false,
        );
      }
    });
  }
}