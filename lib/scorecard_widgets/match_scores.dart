import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/score_providers.dart';
import 'package:cricverse/scorecard_widgets/score_card.dart';
import 'package:cricverse/sub_home_screens/live_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MatchScoreList extends StatefulWidget {
  const MatchScoreList({Key? key}) : super(key: key);

  @override
  State<MatchScoreList> createState() => _MatchScoreListState();
}

class _MatchScoreListState extends State<MatchScoreList> {

  List<String> allowedStatus = ['abandoned', 'live', 'result', 'drinks'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<ScoreProvider>(
      builder: (context, scoreProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              scoreProvider.homeScoreList.isNotEmpty? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: scoreProvider.homeScoreList.length,
                itemBuilder: (context, index){
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
                  return Container(
                    height: 230,
                    margin: const EdgeInsets.only(top: 15),
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: Container(
                            height: 210,
                            width: size.width,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white60)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(scoreProvider.homeScoreList[index].seriesName??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),),
                                        Text(scoreProvider.homeScoreList[index].stadium??'', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),),
                                      ],
                                    ),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: (){print('object');},
                                      child: const CircleAvatar(
                                        backgroundColor: Color(0xffFE00A8),
                                        radius: 13,
                                        child: Icon(Icons.send, size: 15, color: Colors.white,),
                                      ),
                                    ) // share button
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: (){
                              if(index%3==0){
                                scoreProvider.loadAd();
                                scoreProvider.showInterstitialAd();
                              }
                              String url = 'https://hs-consumer-api.espncricinfo.com/v1/pages/match/home?lang=en&seriesId=${scoreProvider.homeScoreList[index].seriesObjectId}&matchId=${scoreProvider.homeScoreList[index].matchObjectId}';
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> ScoreCard(url)));
                            },
                            child: Container(
                              height: 40,
                              width: size.width*0.35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xffFE00A8),
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Text('View ScoreCard', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),),
                            ),
                          ),
                        ) // view score card button
                      ],
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
      },
    );
  }
}
