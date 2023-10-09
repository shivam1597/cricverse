import 'dart:async';
import 'dart:convert';
import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:cricverse/scorecard_widgets/batsmen_score_table.dart';
import 'package:cricverse/scorecard_widgets/bowler_score_table.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScorecardTab extends StatefulWidget {
  const ScorecardTab({Key? key}) : super(key: key);

  @override
  State<ScorecardTab> createState() => _ScorecardTabState();
}

class _ScorecardTabState extends State<ScorecardTab> with SingleTickerProviderStateMixin{

  String flagCountryName(String countryFlagName){
    if(countryFlagName.contains(' ')){
      List<String> splitName = countryFlagName.split(' ');
      if(splitName.last=='Women'){
        splitName.remove(splitName.last);
      }
      countryFlagName = splitName.join(' ');
    }
    return countryFlagName;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<ScorecardsProvider>(
      builder: (context, scorecardProvider, child){
        return DefaultTabController(
          length: scorecardProvider.innings.isNotEmpty? scorecardProvider.innings.length:0,
          child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: scorecardProvider.matchInfo['matchStatusText'].toString().isNotEmpty? 30: 20,
                backgroundColor: Colors.black,
                centerTitle: true,
                title: Text('${scorecardProvider.matchInfo['matchStatusText']}\n'??'', style: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontSize: 13, fontWeight: FontWeight.w600),),
                bottom: TabBar(
                  physics: const BouncingScrollPhysics(),
                  indicatorColor: Colors.white70,
                  tabs: List.generate(scorecardProvider.innings.isNotEmpty?scorecardProvider.innings.length:0, (index){
                    int teamNameListIndex = index%4==0||index%4==2?0:1;
                    var scoreInfoJson = scorecardProvider.innings[index]['scorecard'];
                    return Tab(
                        child: Row(
                          children: [
                            scorecardProvider.teamNames.isNotEmpty?SvgPicture.network(flagUrlMap[flagCountryName(scorecardProvider.teamNames[teamNameListIndex])]!,
                              height: scorecardProvider.teamNames[teamNameListIndex].contains('West Indies')? 30 :45,)
                                : const Center(),
                            Column(
                              children: [
                                Text(scorecardProvider.teamNames.isNotEmpty? scorecardProvider.teamAbbreviations[teamNameListIndex]:'', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.9), fontWeight: FontWeight.w700),),
                                Text(scorecardProvider.teamNames.isNotEmpty? '${scoreInfoJson['runs']}-${scoreInfoJson['wkts']} (${scorecardProvider.innings[index]['overProgress']} overs)':'', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 11),)
                              ],
                            )
                          ],
                        )
                    );
                  }),
                ),
              ),
              body: TabBarView(
                  children: List.generate(scorecardProvider.innings.isNotEmpty?scorecardProvider.innings.length:0, (index){
                    Map<String, dynamic> extrasMap = scorecardProvider.innings.isNotEmpty?scorecardProvider.innings[index]['scorecard']['extras']:{};
                    List<String> formattedExtras = [];
                    extrasMap.forEach((key, value) {
                      if (value > 0) {
                        String? abbreviation = {
                          "noBallRuns": "NB",
                          "wideRuns": "W",
                          "byeRuns": "B",
                          "legByeRuns": "LB",
                          "penaltyRuns": "P",
                        }[key];
                        if (abbreviation != null) {
                          formattedExtras.add("$abbreviation $value");
                        }
                      }
                    });
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BatsmenScoreTable(size, scorecardProvider, index),
                          Text('\nExtras: ${extrasMap.values.fold(0, (sum, value) => (sum+value).toInt())}, (${formattedExtras.join(", ")})', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                          Text('\nFall Of Wickets\n', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                          RichText(
                            text: TextSpan(
                                children: List.generate(scorecardProvider.innings[index]['scorecard']['fow'].length, (index1){
                                  var fowObject = scorecardProvider.innings[index]['scorecard']['fow'][index1];
                                  String runs = fowObject['r'].toString();
                                  String wicket = fowObject['w'].toString();
                                  int overToShow = fowObject['bp']['over']!=0?fowObject['bp']['over']-1:0;
                                  String balls = fowObject['bp']['ball'].toString();
                                  String playerId = fowObject['playerId'].toString();
                                  return TextSpan(
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                    text: '$wicket-$runs (${scorecardProvider.playersMap[playerId]}, $overToShow.$balls ov), ',
                                  );
                                })
                            ),
                          ),
                          const SizedBox(height: 20,),
                          BowlerScoreTable(size, scorecardProvider, index)
                        ],
                      ),
                    );
                  })
              )
          ),
        );
      },
    );
  }
}
