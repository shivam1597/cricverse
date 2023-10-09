import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {

  BannerAd? _bannerAd;
  // List<dynamic> purchasedProductIds = [];
  //
  // getPurchasedProducts()async{
  //   final box = await Hive.openBox('myBox');
  //   if(box.get('purchased_products')!=null){
  //     purchasedProductIds = box.get('purchased');
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BannerAd(
      // adUnitId: 'ca-app-pub-6190421243004216/7086842085',
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // test
      request: const AdRequest(nonPersonalizedAds: false),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: _bannerAd!=null? _bannerAd!.size.width.toDouble(): 0,
        height: _bannerAd!=null? _bannerAd!.size.height.toDouble():0,
        child: _bannerAd!=null? AdWidget(ad: _bannerAd!): const Center(),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();
    super.dispose();
  }
}
