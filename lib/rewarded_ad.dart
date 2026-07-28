import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static String get _adUnitId => 'ca-app-pub-9862845654788448/9933707638';

  static void _loadAd({required void Function() onLoaded}) {
    if (_isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  static Future<bool> showAd(BuildContext context) async {
    if (_rewardedAd == null) {
      final completer = Completer<bool>();
      _loadAd(onLoaded: () {
        completer.complete(true);
      });
      final loaded = await completer.future;
      if (!loaded || _rewardedAd == null) return false;
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }
}
