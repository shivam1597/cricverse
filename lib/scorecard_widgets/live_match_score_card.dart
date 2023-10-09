import 'dart:convert';

import 'package:cricverse/sub_home_screens/live_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LiveMatchScoreCardWidget extends StatefulWidget {
  String? matchId;
  String? formattedDate;
  String? svgFlag1;
  String? svgFlag2;
  String? team1Abbr;
  String? team2Abbr;
  LiveMatchScoreCardWidget({this.matchId, this.formattedDate, this.svgFlag1, this.svgFlag2, this.team1Abbr, this.team2Abbr, Key? key}) : super(key: key);

  @override
  State<LiveMatchScoreCardWidget> createState() => _LiveMatchScoreCardWidgetState();
}

class _LiveMatchScoreCardWidgetState extends State<LiveMatchScoreCardWidget> {

  List<String> teamNames = [];
  List<Map<String, String>> inningsInfo = [];
  String? team1Name;
  String? team2Name;
  List<dynamic> battingOrder = [];

  void fetchLiveScore()async{
    while(true){
      inningsInfo.clear();
      var response = await http.get(Uri.parse('https://api.icc.cdp.pulselive.com/fixtures/${widget.matchId}/scoring'));
      var jsonObject = json.decode(response.body);
      var matchInfoJson = jsonObject['matchInfo'];
      team1Name = matchInfoJson['teams'][0]['team']['fullName'];
      team2Name = matchInfoJson['teams'][1]['team']['fullName'];
      battingOrder = matchInfoJson['battingOrder'];
      inningsInfo.add({
        'overProgress': jsonObject['innings'][0]['overProgress'],
        'runs': jsonObject['innings'][0]['scorecard']['runs'].toString(),
        'wickets': jsonObject['innings'][0]['scorecard']['wkts'].toString(),
      });
      inningsInfo.add({
        'overProgress': jsonObject['innings'][1]['overProgress'],
        'runs': jsonObject['innings'][1]['scorecard']['runs'].toString(),
        'wickets': jsonObject['innings'][1]['scorecard']['wkts'].toString(),
      });
      if(battingOrder.first==1){
        inningsInfo = inningsInfo.reversed.toList();
      }
      setState(() {});
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLiveScore();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(inningsInfo);
    return GestureDetector(
      onTap: (){
        // print(scoreCardsList[index].team1Innings);
        // if(scoreCardsList[index].state=='L'){
        //   final scorecardProvider = Provider.of<ScorecardsProvider>(context, listen: false);
        //   scorecardProvider.setCurrentMatchId(scoreCardsList[index].matchId!);
        //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const ParentScoreCardTab()));
        // }else{
        //   Navigator.push(context, MaterialPageRoute(builder: (context)=> TeamSquad(scoreCardsList[index].matchId!)));
        // }
      },
      child: Container(
        height: 200,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LiveIndicator(),
                      Text(widget.formattedDate!, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
                    ],
                  ),
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
                            child: SvgPicture.network(widget.svgFlag1!, height: 55,),
                          ),
                          const SizedBox(width: 5,),
                          Text(widget.team1Abbr??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                        ],
                      ),
                      Row(
                        children: [
                          // to be refreshed
                          Text('${inningsInfo.first['runs']}-${inningsInfo.first['wickets']} (${inningsInfo.first['overProgress']})',
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
                            child: SvgPicture.network(widget.svgFlag2!, height: 55,),
                          ),
                          const SizedBox(width: 5,),
                          Text(widget.team2Abbr??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                        ],
                      ),
                      Row(
                        children: [
                          // to be refreshed
                          Text('${inningsInfo.last['runs']}-${inningsInfo.last['wickets']} (${inningsInfo.last['overProgress']})',
                            style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                        ],
                      )
                    ],
                  ), // team 2 flags and score
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // may need to be refreshed
                      // Text(scoreCardsList[index].statusText??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center,)
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
  }
}
