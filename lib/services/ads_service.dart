import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static AdService get instance => _instance;

  static const String _rewardedAdUnitIdAndroid = 'ca-app-pub-7635498647186771/2254205775';
  static const String _rewardedAdUnitIdIOS = 'ca-app-pub-7635498647186771/2254205775';

  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-7635498647186771/9888334978';
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-7635498647186771/9888334978';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;

  bool get isRewardedAdReady => _isRewardedAdReady;
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('Mobile Ads SDK initialized successfully');

      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      debugPrint(' Error initializing Mobile Ads SDK: $e');
    }
  }

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _rewardedAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _rewardedAdUnitIdIOS;
    }
    return _rewardedAdUnitIdAndroid;
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialAdUnitIdIOS;
    }
    return _interstitialAdUnitIdAndroid;
  }

  Future<void> loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isRewardedAdReady = true;

            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint(' Rewarded ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Rewarded ad dismissed');
                ad.dispose();
                _isRewardedAdReady = false;
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint(' Rewarded ad failed to show: $error');
                ad.dispose();
                _isRewardedAdReady = false;
                loadRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint(' Rewarded ad failed to load: $error');
            _rewardedAd = null;
            _isRewardedAdReady = false;

            Future.delayed(const Duration(seconds: 10), () {
              loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint(' Error loading rewarded ad: $e');
      _isRewardedAdReady = false;
    }
  }

  Future<bool> showRewardedAd({
    required Function() onAdWatched,
    required Function() onAdCancelled,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint(' Rewarded ad is not ready yet');
      onAdWatched(); // or onAdCancelled(), depending on your logic
      return false;
    }

    bool userWatchedAd = false;
    bool callbackExecuted = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(' Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(' Rewarded ad dismissed - User watched: $userWatchedAd');

        if (!callbackExecuted) {
          callbackExecuted = true;
          if (userWatchedAd) {
            onAdWatched();
          } else {
            onAdCancelled();
          }
        }

        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(' Rewarded ad failed to show: $error');

        if (!callbackExecuted) {
          callbackExecuted = true;
          onAdCancelled();
        }

        ad.dispose();
        _isRewardedAdReady = false;
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(' User earned reward: ${reward.amount} ${reward.type}');
        userWatchedAd = true;
      },
    );

    return true;
  }

  Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialAdReady = true;

            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint(' Interstitial ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint(' Interstitial ad dismissed');
                ad.dispose();
                _isInterstitialAdReady = false;
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint(' Interstitial ad failed to show: $error');
                ad.dispose();
                _isInterstitialAdReady = false;
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint(' Interstitial ad failed to load: $error');
            _interstitialAd = null;
            _isInterstitialAdReady = false;

            Future.delayed(const Duration(seconds: 10), () {
              loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint(' Error loading interstitial ad: $e');
      _isInterstitialAdReady = false;
    }
  }

  Future<void> showInterstitialAd({
    required Function() onAdClosed,
  }) async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint(' Interstitial ad is not ready yet');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(' Interstitial ad dismissed');
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        onAdClosed();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(' Interstitial ad failed to show: $error');
        ad.dispose();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        onAdClosed();
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd = null;
    _interstitialAd = null;
    _isRewardedAdReady = false;
    _isInterstitialAdReady = false;
  }
}
