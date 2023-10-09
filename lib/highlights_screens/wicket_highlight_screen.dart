import 'dart:convert';
import 'dart:io';
import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:cricverse/highlights_screens/wicket_highlight_videos.dart';
import 'package:cricverse/providers/cwc_highlights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class WicketHighlightScreen extends StatefulWidget {
  const WicketHighlightScreen({Key? key}) : super(key: key);

  @override
  State<WicketHighlightScreen> createState() => _WicketHighlightScreenState();
}

class _WicketHighlightScreenState extends State<WicketHighlightScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<CricketHighlightProvider>(context, listen: false);
      provider.fetchMatches();
    });
  }
  
  void parseEmoji()async{
    File file = File('/storage/emulated/0/Download/country_flag.json');
    var response = await get(Uri.parse('https://cdn.jsdelivr.net/npm/country-flag-emoji-json@2.0.0/dist/by-code.json'));
    var jsonObject = json.decode(response.body) as Map<String, dynamic>;
    Map<String, String> countryFlags = {};
    jsonObject.forEach((key, value) {
      String countryName = value['name'];
      String countryFlagUrl = value['image'];
      countryFlags[countryName]=countryFlagUrl;
    });
    await file.writeAsString(json.encode(countryFlags));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<CricketHighlightProvider>(
      builder: (context, wicketHighlightProvider, child){
        return SizedBox(
          height: 165,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Text('Watch Fall Of Wickets', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
              SizedBox(
                height: 127,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: wicketHighlightProvider.worldCupMatches.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: ()async{
                        wicketHighlightProvider.showProgressDialog(context);
                        await wicketHighlightProvider.fetchMatchScoreCard(wicketHighlightProvider.worldCupMatches[index]['matchId']);
                        if(mounted){
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> const WicketHighlightVideos()));
                        }
                      },
                      child: Container(
                          height: 230,
                          width: 170,
                          // padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                width: 169,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                    border: Border.all(color: const Color(0xffFE00A8), width: 2)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    wicketHighlightProvider.worldCupMatches[index]['team1']=='West Indies'?
                                    SvgPicture.network(flagUrlMap[wicketHighlightProvider.worldCupMatches[index]['team1']]!, height: 40, width: 40, fit: BoxFit.cover,)
                                        : SvgPicture.network(flagUrlMap[wicketHighlightProvider.worldCupMatches[index]['team1']]!, height: 60, width: 60, fit: BoxFit.cover,),
                                    // Text(wicketHighlightProvider.worldCupMatches[index]['team1'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 25),),
                                    Text('V/S', style: GoogleFonts.rubikPixels(color: const Color(0xffFE00A8), fontWeight: FontWeight.w300, fontSize: 25),),
                                    wicketHighlightProvider.worldCupMatches[index]['team2']=='West Indies'?
                                    SvgPicture.network(flagUrlMap[wicketHighlightProvider.worldCupMatches[index]['team2']]!, height: 40, width: 40, fit: BoxFit.cover,)
                                        : SvgPicture.network(flagUrlMap[wicketHighlightProvider.worldCupMatches[index]['team2']]!, height: 60, width: 60, fit: BoxFit.cover,),
                                    // Text(wicketHighlightProvider.worldCupMatches[index]['team2'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 25),),
                                  ],
                                ),
                              ),
                              Text('Fall Of Wickets',
                                style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.center,
                              ),
                              Container(
                                height: 35,
                                padding: const EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                    color: const Color(0xffFE00A8),
                                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(12)),
                                    border: Border.all(color: const Color(0xffFE00A8))
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_circle, color: Colors.white,),
                                    Text('   Play Now', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),)
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
