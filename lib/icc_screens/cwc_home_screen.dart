import 'dart:async';
import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/icc_screens/cwc_tickets_home.dart';
import 'package:cricverse/icc_screens/cwcnews.dart';
import 'package:cricverse/icc_screens/wc_fixtures.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/cwc_tickets_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IccHomeScreen extends StatefulWidget {
  const IccHomeScreen({Key? key}) : super(key: key);

  @override
  State<IccHomeScreen> createState() => _IccHomeScreenState();
}

class _IccHomeScreenState extends State<IccHomeScreen> {
  int index = 0;
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<AdsProvider>(context, listen: false);
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        // provider.loadAd();
        // provider.showInterstitialAd();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 56,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 0;
                    });
                  },
                  child: SizedBox(
                    height: 45,
                    width: size.width*0.3,
                    child: Column(
                      children: [
                        Text('Fixtures', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),),
                        AnimatedContainer(
                            height: 2,
                            width: size.width*0.45,
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              color: index==0? Colors.grey[800]:Colors.black,
                              borderRadius: BorderRadius.circular(10)
                        ))
                      ],
                    ),
                  ),
                ),// fixtures
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 1;
                    });
                  },
                  child: SizedBox(
                    height: 45,
                    width: size.width*0.3,
                    child: Column(
                      children: [
                        Text('News', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),),
                        AnimatedContainer(
                          height: 2,
                          width: size.width*0.45,
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                              color: index==1? Colors.grey[800]:Colors.black,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        )
                      ],
                    ),
                  ),
                ), // news
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 2;
                    });
                    Provider.of<CwcTicketProvider>(context,listen: false).fetchCwcTickets();
                  },
                  child: SizedBox(
                    height: 45,
                    width: size.width*0.3,
                    child: Column(
                      children: [
                        Text('Tickets', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),),
                        AnimatedContainer(
                          height: 2,
                          width: size.width*0.45,
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                              color: index==2? Colors.grey[800]:Colors.black,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        )
                      ],
                    ),
                  ),
                ), // tickets
              ],
            ),
            const BannerAdWidget(),
            if(index==0)
              const Expanded(child: WCFixtures()),
            if(index==1)
              const Expanded(child: CwcNewsScreen()),
            if(index==2)
              const Expanded(child: CwcTicketsHome())
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer!.cancel();
  }
}
