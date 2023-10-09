import 'package:cricverse/providers/score_providers.dart';
import 'package:cricverse/scorecard_widgets/score_card.dart';
import 'package:cricverse/sub_home_screens/live_animation.dart';
import 'package:cricverse/team_squads.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreenScoreList extends StatefulWidget {
  const HomeScreenScoreList({Key? key}) : super(key: key);

  @override
  State<HomeScreenScoreList> createState() => _HomeScreenScoreListState();
}

class _HomeScreenScoreListState extends State<HomeScreenScoreList> {

  List<String> allowedStatus = ['abandoned', 'live', 'result', 'drinks'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<ScoreProvider>(context, listen: false);
      provider.fetchLiveScores();
      provider.loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<ScoreProvider>(
      builder: (context, scoreProvider, child){
        return scoreProvider.homeScoreList.isNotEmpty? SizedBox(
          height: 215,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index){
              GlobalKey itemKey = GlobalKey();
              String scoreInfo1 = scoreProvider.homeScoreList[index].team1ScoreInfo!.isNotEmpty?'${scoreProvider.homeScoreList[index].team1ScoreInfo}'??'':'';
              String statusToShow = scoreProvider.homeScoreList[index].statusText??'';
              if(scoreInfo1.contains(',')){
                scoreInfo1 = scoreInfo1.split(',').first;
                scoreInfo1 = '($scoreInfo1)';
              }
              String scoreInfo2 = scoreProvider.homeScoreList[index].team2ScoreInfo!.isNotEmpty?'${scoreProvider.homeScoreList[index].team2ScoreInfo}'??'':'';
              if(scoreInfo2.contains(',')){
                scoreInfo2 = scoreInfo2.split(',').first;
                scoreInfo2 = '($scoreInfo2)';
              }
              if(scoreProvider.homeScoreList[index].statusText!=null&&scoreProvider.homeScoreList[index].statusText!.contains('MATCH_START_HOURS') && scoreProvider.homeScoreList[index].startTime!=null){
                final currentTime = DateTime.now();
                DateTime dateTime = DateTime.parse(scoreProvider.homeScoreList[index].startTime!);
                Duration difference = dateTime.difference(currentTime);
                int hours = difference.inHours;
                int minutes = (difference.inMinutes % 60);
                // Format the result
                String formattedDifference = "${hours.toString().padLeft(2, '0')} hours ${minutes.toString().padLeft(2, '0')} minutes";
                statusToShow = scoreProvider.homeScoreList[index].statusText!.split('{').first + formattedDifference;
              }
              return GestureDetector(
                onTap: (){
                  if(index%3==0){
                    scoreProvider.loadAd();
                    scoreProvider.showInterstitialAd();
                  }
                  if(scoreProvider.homeScoreList[index].state=='PRE'){
                    final timestamp = DateTime.parse(scoreProvider.homeScoreList[index].startTime!).toLocal(); // Convert to local time
                    // defining a custom date format
                    final customFormat = DateFormat("d MMM, y 'at' h:mm a 'IST'", "en_IN");
                    final formattedTimestamp = customFormat.format(timestamp);
                    scoreProvider.squadPlayersList.clear();
                    String url = 'https://hs-consumer-api.espncricinfo.com/v1/pages/match/squad-players?lang=en&seriesId=${scoreProvider.homeScoreList[index].seriesObjectId}&matchId=${scoreProvider.homeScoreList[index].matchObjectId}';
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamSquad(url, scoreProvider.homeScoreList[index].statusText!, formattedTimestamp)));
                  }
                  if(scoreProvider.homeScoreList[index].team1Score!=null){
                    String url = 'https://hs-consumer-api.espncricinfo.com/v1/pages/match/home?lang=en&seriesId=${scoreProvider.homeScoreList[index].seriesObjectId}&matchId=${scoreProvider.homeScoreList[index].matchObjectId}';
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ScoreCard(url)));
                  }else if(scoreProvider.homeScoreList[index].state!='PRE'&&scoreProvider.homeScoreList[index].team1Score!=null){
                    Fluttertoast.showToast(msg: 'No score available for this match');
                  }
                },
                child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(right: 10),
                    child: Container(
                      height: 210,
                      width: size.width*0.8,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white60)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RepaintBoundary(
                            key: itemKey,
                           child: Column(
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   scoreProvider.homeScoreList[index].status=='Live'?const LiveIndicator()
                                       :Text(allowedStatus.contains(scoreProvider.homeScoreList[index].status!.toLowerCase())?scoreProvider.homeScoreList[index].status??'':'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
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
                                       scoreProvider.homeScoreList[index].team1FlagUrl!=null?CircleAvatar(
                                         backgroundColor: Colors.transparent,
                                         backgroundImage: NetworkImage('https://www.espncricinfo.com${scoreProvider.homeScoreList[index].team1FlagUrl.toString()}'),
                                       ): const CircleAvatar(backgroundColor: Colors.transparent,),
                                       const SizedBox(width: 5,),
                                       Text(scoreProvider.homeScoreList[index].team1Name??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                     ],
                                   ),
                                   Row(
                                     children: [
                                       Text('$scoreInfo1  ',
                                         style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                                       Text(scoreProvider.homeScoreList[index].team1Score??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
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
                                       scoreProvider.homeScoreList[index].team2FlagUrl!=null?CircleAvatar(
                                         backgroundColor: Colors.transparent,
                                         backgroundImage: NetworkImage('https://www.espncricinfo.com${scoreProvider.homeScoreList[index].team2FlagUrl.toString()}'),
                                       ): const CircleAvatar(backgroundColor: Colors.transparent,),
                                       const SizedBox(width: 5,),
                                       Text(scoreProvider.homeScoreList[index].team2Name??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                     ],
                                   ),
                                   Row(
                                     children: [
                                       Text('$scoreInfo2  ', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                                       Text(scoreProvider.homeScoreList[index].team2Score??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),),
                                     ],
                                   )
                                 ],
                               ), // team 2 flags and score
                               const SizedBox(height: 5,),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text(statusToShow??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center,)
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
                                onTap: ()=> scoreProvider.takeScreenShotAndShare(itemKey),
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
                    )
                ),
              );
            },
          ),
        )
            : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),);
      },
    );
  }
}
