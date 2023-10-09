import 'dart:async';

import 'package:cricverse/icc_screens/flags_info.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:cricverse/icc_screens/wc_last_5_matches.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'cwc_weather.dart';

class WCFixtures extends StatefulWidget {
  const WCFixtures({Key? key}) : super(key: key);

  @override
  State<WCFixtures> createState() => _WCFixturesState();
}

class _WCFixturesState extends State<WCFixtures> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<WorldCupFixtureProvider>(context, listen: false);
      provider.getFixtures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<WorldCupFixtureProvider>(
      builder: (context, fixtureProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: fixtureProvider.fixtures.length,
            itemBuilder: (context, index){
              final GlobalKey itemKey = GlobalKey();
              String originalDateString = fixtureProvider.fixtures[index]['startDate'];

              // Parse the original date string to a DateTime object
              DateTime originalDate = DateTime.parse(originalDateString);

              // Format the date in "dddd DD MMMM" format
              String formattedDate = DateFormat('EEEE dd MMMM').format(originalDate);
              return Container(
                height: 215,
                width: size.width,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white60)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      key: itemKey,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Text(fixtureProvider.fixtures[index]['localDate'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),),
                              Text(fixtureProvider.fixtures[index]['stadium'].replaceAll('Dharamsala', 'Dharamshala')??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Divider(height: 2, color: Colors.grey[700],),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(formattedDate??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
                                ],
                              ),
                              SizedBox(width: size.width*0.06,),
                              SizedBox(
                                width: size.width*0.35,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        flags[fixtureProvider.fixtures[index]['team1Name']]!=null?CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 20,
                                          child: Image.network(flags[fixtureProvider.fixtures[index]['team1Name']]!),
                                        ): const Icon(FontAwesomeIcons.trophy, color: Colors.white70, size: 40,),
                                        const SizedBox(width: 5,),
                                        Text(fixtureProvider.fixtures[index]['team1Name'].replaceAll('Semi-Final 1 Men','SF 1'), style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                      ],
                                    ), // team 1 flags and score
                                    const SizedBox(height: 2.5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text('v/s', style: GoogleFonts.mada(color: Colors.white60, fontWeight: FontWeight.w800),)],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        flags[fixtureProvider.fixtures[index]['team2Name']]!=null?CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 20,
                                          child: Image.network(flags[fixtureProvider.fixtures[index]['team2Name']]!),
                                        ) : const Icon(FontAwesomeIcons.trophy, color: Colors.white70, size: 40,),
                                        const SizedBox(width: 5,),
                                        Text(fixtureProvider.fixtures[index]['team2Name'].replaceAll('Semi-Final 2 Men','SF 2')??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                      ],
                                    ), // team 2 flags and score
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15,),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: ()async{
                            if(fixtureProvider.fixtures[index]['team1Name']=='India'||fixtureProvider.fixtures[index]['team2Name']=='India'){
                              final provider = Provider.of<AdsProvider>(context, listen: false);
                              provider.loadAd();
                              provider.showInterstitialAd();
                            }
                            var matchCentreMap = await fixtureProvider.getRankings(fixtureProvider.fixtures[index]['href']);
                            showMoreDialog(size, fixtureProvider.fixtures[index]['team1Name'], fixtureProvider.fixtures[index]['team2Name'], matchCentreMap);
                          },
                          child: Container(
                            height: 30,
                            width: size.width*0.25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xffFE00A8)
                            ),
                            child: Text('More', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 18),),
                          ),
                        ), // more button
                        GestureDetector(
                          onTap: () {
                            if(fixtureProvider.fixtures[index]['team1Name']=='India'||fixtureProvider.fixtures[index]['team2Name']=='India'){
                              final provider = Provider.of<AdsProvider>(context, listen: false);
                              provider.loadAd();
                              provider.showInterstitialAd();
                            }
                            fixtureProvider.takeScreenShotAndShare(
                                itemKey, '',
                                context: context);
                          },
                          child: Container(
                            height: 30,
                            width: size.width*0.25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xffFE00A8)
                            ),
                            child: Text('Share', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 18),),
                          ),
                        ), // share button
                        GestureDetector(
                          onTap: ()async{
                            if(fixtureProvider.fixtures[index]['team1Name']=='India'||fixtureProvider.fixtures[index]['team2Name']=='India'){
                              final provider = Provider.of<AdsProvider>(context, listen: false);
                              provider.loadAd();
                              provider.showInterstitialAd();
                            }
                            fixtureProvider.handleWeatherContainerHeightChange(context, false);
                            String cityName = fixtureProvider.fixtures[index]['stadium'].toString().split(',').last;
                            showWeatherDialog(cityName);
                            fixtureProvider.weatherReport.clear();
                            fixtureProvider.fetchWeather(fixtureProvider.venueIdsForWeather[cityName.trim()]!.values.first,fixtureProvider.venueIdsForWeather[cityName.trim()]!.keys.first);
                          },
                          child: Container(
                            height: 30,
                            width: size.width*0.25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xffFE00A8)
                            ),
                            child: Text('Weather', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 18),),
                          ),
                        ), // weather button
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  showMoreDialog(Size size, String team1, String team2, Map<String, dynamic> matchCentreMap){
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context){
        return WCLast5Matches(size, team1, matchCentreMap, team2);
      }
    );
  }

  showWeatherDialog(String cityName){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        builder: (context){
          return CwcWeather(cityName);
        }
    );
  }
}
