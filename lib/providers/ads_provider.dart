import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AdsProvider extends ChangeNotifier{
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

  Future<void> showInterstitialAd() async {
    _interstitialAd!.show();
  }

  // Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
  //   // IMPORTANT!! Always verify a purchase before delivering the product.
  //   // For the purpose of an example, we directly return true.
  //   return Future<bool>.value(true);
  // }
  //
  // Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
  //   final box = await Hive.openBox('myBox');
  //   List<dynamic> purchasedProductIds = [];
  //   if(box.get('purchased_products')!=null){
  //     purchasedProductIds = box.get('purchased');
  //   }
  //   for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       // showPendingUI(); add progress indicator
  //     } else {
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         handleError(purchaseDetails.error!);
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
  //         final bool valid = await _verifyPurchase(purchaseDetails);
  //         if (valid) {
  //           purchasedProductIds.add(purchaseDetails.productID);
  //           box.put('purchased_products', purchasedProductIds);
  //         }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await InAppPurchase.instance.completePurchase(purchaseDetails);
  //       }
  //     }
  //   }
  // }
  //
  // void handleError(IAPError error) {
  //   purchasePending = false;
  //   Fluttertoast.showToast(msg: 'Error in purchasing the subscription');
  //   notifyListeners();
  // }


}