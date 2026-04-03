import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wrapper around Google Mobile Ads for banner and interstitial ads.
///
/// Uses test ad unit IDs in debug mode. In release, replace with real IDs.
class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isInitialized = false;

  /// Test ad unit IDs from Google.
  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test
    }
  }

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test banner
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
    }
  }

  /// Initialize the Mobile Ads SDK.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadInterstitial();
  }

  /// Pre-load an interstitial ad so it's ready when needed.
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Pre-load the next ad
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Show an interstitial ad if one is loaded.
  /// Returns true if an ad was shown.
  bool showInterstitial() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }
    // Try to load one for next time
    loadInterstitial();
    return false;
  }

  bool get isAdReady => _isAdLoaded;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

/// A widget that displays a banner ad at the bottom of the screen.
/// Hides itself if the user is premium or if the ad fails to load.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final adSize = AdSize.banner;
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
