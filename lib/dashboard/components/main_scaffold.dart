import 'package:flutter/material.dart';

import '../../google_ads.dart';
import '../../service/auth.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final String? title;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showBottomBar;


  const MainScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.title,
    this.titleStyle,
    this.actions,
    this.showAppBar = true,
    this.showBottomBar = true,

  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final authMethods = AuthMethods();
  final GoogleAds? googleAds = GoogleAds();
  @override
  void initState() {
    super.initState();
    googleAds?.loadInterstitialAd();
    googleAds?.loadBannerAd(adLoaded: () {
      setState(() {

      });
    },);
  }

  @override
  void dispose() {
    googleAds?.bannerAd?.dispose();
    googleAds?.interstitialAd?.dispose();
    super.dispose();
  }

  void handleTabChange(int index) async {
    if (widget.currentIndex == index) return;

    if (googleAds != null) {
       googleAds!.showInterstitialAd();
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/fatwa');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/coach');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: widget.showAppBar
          ? AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        elevation: 0,
        title: widget.title != null
            ? Text(widget.title!, style: widget.titleStyle)
            : Container(
          alignment: Alignment.centerLeft,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.amber,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/selam_kapisi_logo.png',
              height: 60,
            ),
          ),
        ),
        actions: [
          if (widget.actions != null) ...widget.actions!,
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => authMethods.signOut(context),
            ),
          ),
        ],
      )
          : null,
      body: widget.body,
      bottomNavigationBar: widget.showBottomBar
          ? BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: handleTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Fetva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Koç',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      )
          : null,
    );
  }
}
