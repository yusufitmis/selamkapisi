import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds{
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

  // TODO: replace this test ad unit with your own ad unit.

  void loadInterstitialAd({bool showAfterLoad = false}) {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(

          onAdLoaded: (ad) {
            interstitialAd = ad;
            if(showAfterLoad) showInterstitialAd();
          },

          onAdFailedToLoad: (LoadAdError error) {

          },
        ));
  }
  void showInterstitialAd(){
    if(interstitialAd != null){
      interstitialAd!.show();
    }
  }

  /// Loads a banner ad.
  void loadBannerAd({required VoidCallback adLoaded})  {

    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          adLoaded();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }
}