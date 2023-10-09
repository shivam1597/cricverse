import 'dart:async';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/twitter_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TwitterTagsWidget extends StatefulWidget {
  Size size;
  TwitterTagsWidget(this.size, {Key? key}) : super(key: key);

  @override
  State<TwitterTagsWidget> createState() => _TwitterTagsWidgetState();
}

class _TwitterTagsWidgetState extends State<TwitterTagsWidget> {

  Timer? timer;
  int timerSeconds = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<TwitterProvider>(context, listen: false);
      provider.getTwitterTagsInformation();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {timerSeconds++;});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TwitterProvider>(
      builder: (context, twitterProvider, child){
        return twitterProvider.dataValue==null? const Center(
          child: CircularProgressIndicator(color: Color(0xffFE00A8),),
        ):
        twitterProvider.hasToShow?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trending On CricVerse', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
            const SizedBox(height: 5,),
            SizedBox(
              height: 50,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  ...twitterProvider.dataValue!.entries.map((e){
                    return GestureDetector(
                      onTap: () {
                        final provider = Provider.of<AdsProvider>(context, listen: false);
                        if(timerSeconds%7==0||timerSeconds%11==0){
                          provider.loadAd();
                          provider.showInterstitialAd();
                        }
                        twitterProvider.getTwitterPostJson(
                            e.value.toString(), context, e.key.toString());
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffFE00A8)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xff310072)
                        ),
                        child: Text('#${e.key.toString()}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      ),
                    );
                  })
                ],
              ),
            )
          ],
        ): const Center();
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer!.cancel();
  }
}

