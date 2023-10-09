import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
class MemeTemplateProvider extends ChangeNotifier{

  Map<String, String> memeTemplates = {};
  int pageCount = 0;

  InterstitialAd? _interstitialAd;

  void loadAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-6190421243004216/5251016233',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  void fetchMemeTemplates()async{
    pageCount++;
    var response = await http.get(Uri.parse('https://imgflip.com/memetemplates?page=$pageCount'));
    final document= parse(response.body);
    final boxesList = document.getElementsByClassName('mt-box');
    for(var box in boxesList){
      final title = box.getElementsByClassName('mt-title').first.getElementsByTagName('a').first.text;
      final imageUrl = box.getElementsByClassName('mt-img-wrap').first.getElementsByTagName('a').first.getElementsByClassName('shadow').first.attributes['src'];
      memeTemplates[title]=imageUrl!;
    }
    notifyListeners();
  }
}