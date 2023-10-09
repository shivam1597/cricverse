import 'dart:async';

import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/rewarded_ads_provider.dart';
import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:cricverse/scorecard_widgets/commentary_screen.dart';
import 'package:cricverse/scorecard_widgets/match_related_news.dart';
import 'package:cricverse/scorecard_widgets/scorecard_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
class ParentScoreCardTab extends StatefulWidget {
  const ParentScoreCardTab({Key? key}) : super(key: key);

  @override
  State<ParentScoreCardTab> createState() => _ParentScoreCardTabState();
}

class _ParentScoreCardTabState extends State<ParentScoreCardTab> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _tabController = DefaultTabController.of(context);
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final adsProvider = Provider.of<RewardedAdsProvider>(context, listen: false);
      final provider = Provider.of<ScorecardsProvider>(context, listen: false);
      adsProvider.loadAd();
      provider.fetchScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<ScorecardsProvider>(
      builder: (context, scorecardProvider, child){
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            backgroundColor: Colors.black,
            actions: [
              GestureDetector(
                onTap: (){
                  final provider = Provider.of<RewardedAdsProvider>(context, listen: false);
                  if(!scorecardProvider.commentaryState){
                    provider.showAd(()=>scorecardProvider.handleCommentaryButtonTap());
                  }else{
                    scorecardProvider.handleCommentaryButtonTap();
                  }
                  // provider.showInterstitialAd();
                  // scorecardProvider.handleCommentaryButtonTap(); // give it as reward.
                },
                child: Container(
                    height: 30,
                    width: size.width*0.37,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xffFE00A8)
                    ),
                    child: Row(
                      children: [
                        Icon(scorecardProvider.commentaryState? Icons.mic :Icons.mic_off, color: Colors.white,),
                        Text('Listen Commentary', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)
                      ],
                    )
                ),
              )
            ],
          ),
          backgroundColor: Colors.black,
          body: IndexedStack(
            index: scorecardProvider.tabsIndex,
            children: [
              scorecardProvider.innings.isNotEmpty? const ScorecardTab(): Center(
                child: Text('Sorry! No score available.', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 18),),
              ),
              scorecardProvider.commentaries.isNotEmpty?CommentaryScreen(size): Center(
                child: Text('Sorry! No commentary available.', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 18),),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: scorecardProvider.tabsIndex,
            onTap: scorecardProvider.handleTabIndex,
            backgroundColor: Colors.black,
            selectedItemColor: const Color(0xffFE00A8),
            selectedLabelStyle: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(),
            unselectedItemColor: Colors.white38,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.query_stats_outlined,),
                  label: 'Score'
              ),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.microphone),
                  label: 'Commentary'
              ),
            ],
          ),
        );
      },
    );
  }

}
