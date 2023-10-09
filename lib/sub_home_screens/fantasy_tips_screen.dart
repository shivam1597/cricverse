import 'dart:convert';

import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/news_screens/news_browser.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';
class FantasyTips extends StatefulWidget {
  const FantasyTips({Key? key}) : super(key: key);

  @override
  State<FantasyTips> createState() => _FantasyTipsState();
}

class _FantasyTipsState extends State<FantasyTips> {

  List<Map<String, dynamic>> fantasyMatches = [];
  //https://www.crictracker.com/fantasy-cricket-tips/?ref=hm&dDay=2023-09-12
  void parseHtml()async{
    String endPoint = 'https://www.crictracker.com/fantasy-cricket-tips/?ref=hm&dDay=2023-09-12';
    String date = '';
    var response = await http.get(Uri.parse('$endPoint$date'));
    var document = html_parser.parse(response.bodyBytes);
    var mainContainer = document.getElementsByClassName('undefined mt-4');
    for(var v in mainContainer){
      Map<String, dynamic> mapToAdd = {};
      mapToAdd['seriesUrl'] = v.getElementsByTagName('a').first.attributes['href']!;
      mapToAdd['seriesName'] = v.getElementsByTagName('a').first.text;
      mapToAdd['matchTime'] = v.getElementsByClassName('undefined mb-0').first.text;
      final flagDiv1 = v.getElementsByClassName('undefined d-flex align-items-center').first;
      mapToAdd['team1'] = flagDiv1.getElementsByTagName('p').first.text;
      // String team1 = flagDiv1.getElementsByTagName('p').first.text;
      final flagDiv2 = v.getElementsByClassName('undefined d-flex align-items-center').last;
      mapToAdd['team2'] = flagDiv2.getElementsByTagName('p').last.text;
      if(v.getElementsByClassName('style_tipsBtn__a5OIV style_dream11__jLZNg d-flex align-items-center mb-1 mt-1 mb-md-2 mt-sm-2').isNotEmpty){
        mapToAdd['matchCenterUrl'] = v.getElementsByClassName('style_tipsBtn__a5OIV style_dream11__jLZNg d-flex align-items-center mb-1 mt-1 mb-md-2 mt-sm-2').first.attributes['href'];
      }else{
        mapToAdd['matchStatus'] = v.getElementsByClassName('mb-1 mb-md-0').first.text;
      }
      mapToAdd['matchLocation'] = v.getElementsByClassName('text-muted font-semi mb-0').first.text;
      fantasyMatches.add(mapToAdd);
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parseHtml();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          fantasyMatches.isNotEmpty? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: fantasyMatches.length,
            itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListTile(
                    onTap: (){
                      // using provider so this screen won't be filled with code
                      if(index%3==0){
                        final provider = Provider.of<WorldCupFixtureProvider>(context, listen: false);
                        provider.loadAd();
                        provider.showInterstitialAd();
                      }
                      if(fantasyMatches[index].containsKey('matchCenterUrl')){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser('https://www.crictracker.com${fantasyMatches[index]['matchCenterUrl']}')));
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    tileColor: Colors.grey[900],
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser('https://www.crictracker.com${fantasyMatches[index]['seriesUrl']}'))),
                          child: Row(
                            children: [
                              Text('${fantasyMatches[index]['seriesName']}   ', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),),
                              const Icon(Icons.open_in_new, color: Color(0xffFE00A8), size: 20,)
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${fantasyMatches[index]['team1']} vs ${fantasyMatches[index]['team2']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Text('${fantasyMatches[index]['matchTime']}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),)
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            if(index%3==0){
                              final provider = Provider.of<WorldCupFixtureProvider>(context, listen: false);
                              provider.loadAd();
                              provider.showInterstitialAd();
                            }
                            if(fantasyMatches[index].containsKey('matchCenterUrl')){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser('https://www.crictracker.com${fantasyMatches[index]['matchCenterUrl']}')));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                                color: fantasyMatches[index].containsKey('matchCenterUrl')? const Color(0xffFE00A8): Colors.transparent,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: fantasyMatches[index].containsKey('matchCenterUrl')?Text('Open', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),)
                                : Text(fantasyMatches[index]['matchStatus'], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        )
                      ],
                    )
                ),
              );
            },
          )
              : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
          const Positioned(
            bottom: 5,
            child: BannerAdWidget(),
          )
        ],
      )
    );
  }
}
