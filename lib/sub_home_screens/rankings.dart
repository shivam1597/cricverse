import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/ranking_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../coin_player_info.dart';

class Rankings extends StatefulWidget {
  const Rankings({Key? key}) : super(key: key);

  @override
  State<Rankings> createState() => _RankingsState();
}

class _RankingsState extends State<Rankings> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<RankingProvider>(context, listen: false);
      provider.fetchTeamRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<RankingProvider>(
      builder: (context, rankingProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Container(
                  width: size.width,
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40,),
                      SizedBox(
                        height: 60,
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(rankingProvider.formatList.length, (index){
                            return GestureDetector(
                              onTap: (){
                                if(index%2==0){
                                  final provider = Provider.of<AdsProvider>(context, listen: false);
                                  // provider.loadAd();
                                  // provider.showInterstitialAd();
                                }
                                rankingProvider.handleFormatChange(rankingProvider.formatList[index]);
                              },
                              child: Container(
                                width: size.width*0.24,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: rankingProvider.formatList[index]==rankingProvider.selectedFormat? Colors.grey[600] :const Color(0xffFE00A8).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Text(rankingProvider.formatList[index], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                              ),
                            );
                          }),
                        ),
                      ),
                      const BannerAdWidget(),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 60,
                        width: size.width,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: List.generate(rankingProvider.rankTypeList.length, (index){
                            return GestureDetector(
                              onTap: (){
                                if(index%2==0){
                                  final provider = Provider.of<AdsProvider>(context, listen: false);
                                  provider.loadAd();
                                  provider.showInterstitialAd();
                                }
                                rankingProvider.handleRankingTypeChange(rankingProvider.rankTypeList[index]);
                              },
                              child: Container(
                                width: size.width*0.24,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: rankingProvider.rankTypeList[index]==rankingProvider.selectedRankType? Colors.grey[600] :const Color(0xffFE00A8).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Text(rankingProvider.rankTypeList[index], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text('${rankingProvider.selectedFormat} ${rankingProvider.selectedRankType} Ranking', style: GoogleFonts.poppins(color: Colors.red[300], fontWeight: FontWeight.w600, fontSize: 22),),
                      const SizedBox(height: 10,),
                      ListTile(
                        leading: Text('Rank', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                        title: Text(rankingProvider.rankUrl.contains('teams')?'Team Name':'Player Name', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                        trailing: Text('Rating', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                      ),
                      rankingProvider.selectedRankType!='Teams'?Text('Tap on the player name for more details.', style: GoogleFonts.poppins(color: Colors.red[300], fontWeight: FontWeight.w700, fontSize: 10),): const Center(),
                      Expanded(
                        child: rankingProvider.rankingToShow.isNotEmpty? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: rankingProvider.rankingToShow.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              onTap: (){
                                if(rankingProvider.selectedRankType!='Teams'){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> CoinPlayerInfo(rankingProvider.rankingToShow[index].profileUrl!)));
                                }
                              },
                              leading: Text('${index+1}', style: GoogleFonts.poppins(color: Colors.white70),),
                              title: Text(rankingProvider.rankingToShow[index].title!, style: GoogleFonts.poppins(color: Colors.white70),),
                              subtitle: Text(rankingProvider.rankUrl.contains('teams')?'':rankingProvider.ranking[index].country!, style: GoogleFonts.poppins(color: Colors.white70),),
                              trailing: Text(rankingProvider.rankingToShow[index].rating!, style: GoogleFonts.poppins(color: Colors.white70),),
                            );
                          },
                        )
                            : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
                      )
                    ],
                  )
              ),
            ],
          )
        );
      },
    );
  }
}
