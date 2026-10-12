import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  final ValueNotifier<bool> adsRemovedNotifier = ValueNotifier(false);
  bool get adsRemoved => adsRemovedNotifier.value;

  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    final sp = await SharedPreferences.getInstance();
    adsRemovedNotifier.value = sp.getBool('adsRemoved') ?? false;

    if (!adsRemoved) {
      _loadInterstitial();
      _startInterstitialTimer();
    }
  }

  Future<void> setAdsRemoved(bool removed) async {
    adsRemovedNotifier.value = removed;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('adsRemoved', removed);

    if (removed) {
      _interstitialTimer?.cancel();
      _interstitialAd?.dispose();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
      _startInterstitialTimer();
    }
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer.periodic(const Duration(seconds: 90), (_) {
      _showInterstitialIfReady();
    });
  }

  void _showInterstitialIfReady() {
    if (adsRemoved) return;
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialTimer?.cancel();
    _interstitialAd?.dispose();
  }
}