import 'dart:async';
import 'dart:convert';
import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:cricverse/flag_asset/language_names_json.dart';
import 'package:cricverse/models/score_models.dart';
import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:cricverse/scorecard_widgets/live_match_score_card.dart';
import 'package:cricverse/scorecard_widgets/parent_score_card_tab.dart';
import 'package:cricverse/scorecard_widgets/team_squads.dart';
import 'package:cricverse/sub_home_screens/live_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class ScoreTest extends StatefulWidget {
  const ScoreTest({Key? key}) : super(key: key);

  @override
  State<ScoreTest> createState() => _ScoreTestState();
}

class _ScoreTestState extends State<ScoreTest> {

  List<ScoreModel> scoreCardsList = [];
  List<Map<String, String>> liveMatchMap = [];

  int calculateSortOrder(ScoreModel scoreModel) {
    DateTime currentDate = DateTime.now();
    final DateTime matchStartTime = DateTime.parse(scoreModel.startDate!);

    // Check if the match is live
    if (scoreModel.state!.toLowerCase() == 'L') {
      return -1; // Live matches, prioritize them first
    }

    // Check if the match is scheduled for today
    if (matchStartTime.year == currentDate.year &&
        matchStartTime.month == currentDate.month &&
        matchStartTime.day == currentDate.day) {
      return 0; // Other matches starting today, they come after live matches
    }

    // Matches that are not live and not starting today, they come last
    return 1;
  }

  void fetchScoreCards()async{
    DateTime today = DateTime.now();

    DateTime dateBeforeOneDay = today.subtract(const Duration(days: 1));
    // Get the date after 2 days
    DateTime dateAfterTwoDays = today.add(const Duration(days: 3));

    // Format the dates in "yyyy-MM-dd" format
    String formattedDateBeforeOneDay = DateFormat('yyyy-MM-dd').format(dateBeforeOneDay);
    String formattedDateAfterTwoDays = DateFormat('yyyy-MM-dd').format(dateAfterTwoDays);
    var response = await http.get(Uri.parse('https://cricketapi-icc.pulselive.com/fixtures?tournamentTypes=I%2CWI&startDate=$formattedDateBeforeOneDay&endDate=$formattedDateAfterTwoDays&pageSize=100'),headers: {'Account':'ICC'});
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['content']){
      if(v['scheduleEntry']['matchType']!="TEST"){
        ScoreModel scoreModel = ScoreModel(
          team1Name: v['scheduleEntry']['team1']['team']['fullName'], team2Name: v['scheduleEntry']['team2']['team']['fullName'],
          team1Abbr: v['scheduleEntry']['team1']['team']['abbreviation'], team2Abbr: v['scheduleEntry']['team2']['team']['abbreviation'],
          team1Innings: v['scheduleEntry']['team1']['innings'], team2Innings: v['scheduleEntry']['team2']['innings'],
          title: '${v['label']}, ${v['tournamentLabel']}', stadium: '${v['scheduleEntry']['venue']['fullName']}, ${v['scheduleEntry']['venue']['city']}',
          state: v['scheduleEntry']['matchState'], statusText: v['scheduleEntry']['matchStatus']!=null?v['scheduleEntry']['matchStatus']['text']:null,
          startDate: v['scheduleEntry']['matchDate'], matchId:  v['scheduleEntry']['matchId']['id'].toString(),
        );
        scoreCardsList.add(scoreModel);
      }
      scoreCardsList.sort((a, b) => calculateSortOrder(a).compareTo(calculateSortOrder(b)));
    }
    setState(() {});
  }

  Future<void> refreshLiveScore(ScoreModel scoreModel) async {
    // Make an API call to fetch the live score using the match id from API B.
    // Update the match's score property with the new live score.
    scoreModel.team1Innings = [];
    scoreModel.team2Innings = [];
  }
  
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

  String formatDate(String inputDateString){
    DateTime dateTime = DateTime.parse(inputDateString);
    final istDate = dateTime.toLocal();
    // Format the date and time as "08 October, 2023 at 09:35 AM"
    String formattedDate = DateFormat('dd MMMM, y \'at\' hh:mm a').format(istDate);
    return formattedDate;
  }

  String formatInningScore(List<dynamic>? innings){
    String scoreSummary = '';
    if(innings!=null){
      if (innings.length == 1) {
        final inning = innings[0];
        final runs = inning['runs'];
        final wkts = inning['wkts'];
        final ballsFaced = inning['ballsFaced'];
        int overs = ballsFaced ~/ 6;
        int bowledBalls = ballsFaced % 6;
        scoreSummary = '$runs/$wkts ($overs.$bowledBalls)';
      }
      else if (innings.length == 2) {
        final inning1 = innings[0];
        final inning2 = innings[1];
        final runs1 = inning1['runs'];
        final wkts1 = inning1['wkts'];
        final ballsFaced1 = inning1['ballsFaced'];
        int overs1 = ballsFaced1 ~/ 6;
        int bowledBalls1 = ballsFaced1 % 6;
        final runs2 = inning2['runs'];
        final wkts2 = inning2['wkts'];
        final ballsFaced2 = inning2['ballsFaced'];
        int overs2 = ballsFaced2 ~/ 6;
        int bowledBalls2 = ballsFaced2 % 6;
        scoreSummary = '$runs1/$wkts1 ($overs1.$bowledBalls1) & $runs2/$wkts2 ($overs2.$bowledBalls2)';
      }
    }
    return scoreSummary;
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchScoreCards();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: scoreCardsList.length,
            itemBuilder: (context, index){
              return scoreCardsList[index].state=='L'
                  ? LiveMatchScoreCardWidget(matchId: scoreCardsList[index].matchId, formattedDate: formatDate(scoreCardsList[index].startDate!),
                    svgFlag1: flagUrlMap[flagCountryName(scoreCardsList[index].team1Name!)], svgFlag2: flagUrlMap[flagCountryName(scoreCardsList[index].team2Name!)], team1Abbr: scoreCardsList[index].team1Abbr, team2Abbr: scoreCardsList[index].team2Abbr,)
                  :GestureDetector(
                    onTap: (){
                      print(scoreCardsList[index].team1Innings);
                      // if(scoreCardsList[index].state=='L'){
                      //   final scorecardProvider = Provider.of<ScorecardsProvider>(context, listen: false);
                      //   scorecardProvider.setCurrentMatchId(scoreCardsList[index].matchId!);
                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const ParentScoreCardTab()));
                      // }else{
                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=> TeamSquad(scoreCardsList[index].matchId!)));
                      // }
                    },
                    child: Container(
                    height: 190,
                    width: size.width*0.8,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white60)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepaintBoundary(
                          // key: itemKey,
                          child: Column(
                            children: [
                              Text(formatDate(scoreCardsList[index].startDate!), style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
                              const SizedBox(height: 5,),
                              Divider(height: 2, color: Colors.grey[700],),
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: SvgPicture.network(flagUrlMap[flagCountryName(scoreCardsList[index].team1Name!)]??'', height: 55,),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(scoreCardsList[index].team1Abbr??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(formatInningScore(scoreCardsList[index].team1Innings),
                                        style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                                    ],
                                  )
                                ],
                              ), // team 1 flags and score
                              const SizedBox(height: 2.5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: SvgPicture.network(flagUrlMap[flagCountryName(scoreCardsList[index].team2Name!)]??'', height: 55,),
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(scoreCardsList[index].team2Abbr??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(formatInningScore(scoreCardsList[index].team2Innings),
                                        style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                                    ],
                                  )
                                ],
                              ), // team 2 flags and score
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(scoreCardsList[index].statusText??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center,)
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              // onTap: ()=> scoreProvider.takeScreenShotAndShare(itemKey),
                              child: Container(
                                padding: const EdgeInsets.only(top: 6, bottom: 6, left: 12, right: 12),
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xffFE00A8)
                                ),
                                child: Text('Share', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),),
                              ),
                            ) // share button
                          ],
                        )
                      ],
                    ),
                  ),
              );
            },
          ),
        ),
      ),
    );
  }
  
}
