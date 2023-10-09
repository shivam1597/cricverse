import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CwcWeather extends StatelessWidget {
  String cityName;
  CwcWeather(this.cityName, {Key? key}) : super(key: key);

  GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<WorldCupFixtureProvider>(
      builder: (context, wcProvider, child){
        return Stack(
          children: [
            RepaintBoundary(
              key: globalKey,
              child: AnimatedContainer(
                  height: wcProvider.weatherAnimatedContainerHeight,
                  width: size.width,
                  duration: const Duration(milliseconds: 700),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      Text(cityName, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),),
                      const SizedBox(height: 10,),
                      wcProvider.weatherAnimatedContainerHeight>210?gridView(wcProvider):horizontalListView(wcProvider)
                    ],
                  )
              ),
            ),
            wcProvider.weatherAnimatedContainerHeight==210?Positioned(
              right: 3,
              top: 10,
              child: GestureDetector(
                onTap: (){
                  final provider = Provider.of<AdsProvider>(context, listen: false);
                  provider.loadAd();
                  provider.showInterstitialAd();
                  wcProvider.handleWeatherContainerHeightChange(context, true);
                  Future.delayed(const Duration(milliseconds: 500)).then((value){
                    String message = "Here's the current weather in $cityName";
                    wcProvider.takeScreenShotAndShare(globalKey, message, context: context);
                  });
                },
                child: Container(
                  height: 30,
                  width: size.width*0.25,
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xffFE00A8)
                  ),
                  child: Text('Share', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 18),),
                ),
              ),
            ): const Center()
          ],
        );
      },
    );
  }

  Widget horizontalListView(wcProvider){
    return Expanded(
      child: wcProvider.weatherReport.isNotEmpty?ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: wcProvider.weatherReport.length,
        itemBuilder: (context, index){
          return Container(
            height: 152,
            width: 150,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wcProvider.weatherReport[index]['hour']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),),
                        Text(wcProvider.weatherReport[index]['temperature']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),)
                      ],
                    ), // first row with time and temperature
                    SvgPicture.network(wcProvider.weatherReport[index]['icon']!, height: 60,),
                    Text(wcProvider.weatherReport[index]['phrase']!.split('w/').first, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                  ],
                ), // first part of the card
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white70, size: 12,),
                        const SizedBox(width: 2,),
                        Text('Precipitation: ${wcProvider.weatherReport[index]['precipitation']!}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),),
                      ],
                    ), // precipitation row
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.wind, color: Colors.white70, size: 12,),
                        const SizedBox(width: 2,),
                        Text('Wind: ${wcProvider.weatherReport[index]['wind']!}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),),
                      ],
                    ), // wind row
                  ],
                ), // last part of the card
              ],
            ),
          );
        },
      ): const Center(
        child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
    );
  }
  
  Widget gridView(wcProvider){
    return Expanded(
      child: wcProvider.weatherReport.isNotEmpty?GridView.count(
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 1/0.98,
        children: List.generate(wcProvider.weatherReport.length, (index){
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wcProvider.weatherReport[index]['hour']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),),
                        Text(wcProvider.weatherReport[index]['temperature']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),)
                      ],
                    ), // first row with time and temperature
                    SvgPicture.network(wcProvider.weatherReport[index]['icon']!, height: 60,),
                    Text(wcProvider.weatherReport[index]['phrase']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                  ],
                ), // first part of the card
              ],
            ),
          );
        }),
      ): const Center(
        child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
    );
  }
}
