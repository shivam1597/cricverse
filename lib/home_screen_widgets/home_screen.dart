import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/news_screens/news_screen.dart';
import 'package:cricverse/sub_home_screens/fantasy_tips_screen.dart';
import 'package:cricverse/icc_screens/cwc_home_screen.dart';
import 'package:cricverse/providers/score_providers.dart';
import 'package:cricverse/providers/user_details_provider.dart';
import 'package:cricverse/reddit_screens/reddit.dart';
import 'package:cricverse/sub_home_screens/rankings.dart';
import 'package:cricverse/sub_home_screens/user_screen.dart';
import 'package:cricverse/twitter_tags_screen/twitter_tags_widget.dart';
import 'package:cricverse/highlights_screens/wicket_highlight_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../highlights_screens/highlight_stories.dart';
import '../icc_screens/home_screen_icc_videos.dart';
import '../icc_screens/icc-videos.dart';
import 'home_screen_score_cards.dart';
import 'news_home_screen_list.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      // final provider = Provider.of<TimerProvider>(context, listen: false);
      // final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);
      final userDetailProvider = Provider.of<UserDetailsProvider>(context, listen: false);
      // provider.startTimer();
      // scoreProvider.fetchCoins();
      userDetailProvider.verifyUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: ()async{
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      },
      child: Consumer<ScoreProvider>(
        builder: (context, scoreProvider, child){
          return SafeArea(
            child: Scaffold(
              key: scaffoldKey,
              drawer: UserScreen(scoreProvider: scoreProvider),
              backgroundColor: Colors.black,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.black,
                // has to be implemented
                // title: Row(
                //   children: [
                //     Text('Your Balance: ₹ ${scoreProvider.balanceAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),),
                //   ],
                // ),
                title: GestureDetector(
                  onTap: ()=> scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn),
                  child: Image.asset('assets/images/cric_verse_icon.png', height: 45,),
                ),
                actions: [
                  GestureDetector(
                    onTap: (){
                      if(scaffoldKey.currentState!.isDrawerOpen){
                        scaffoldKey.currentState!.closeDrawer();
                        //close drawer, if drawer is open
                      }else{
                        scaffoldKey.currentState!.openDrawer();
                        //open drawer, if drawer is closed
                      }
                    },
                    child: const Icon(FontAwesomeIcons.user, color: Colors.white60,),
                  )
                ],
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const IccHomeScreen())),
                      child: Container(
                        height: 85,
                        width: size.width,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffFE00A8)),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xff310072)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.sports_cricket_outlined, size: 40, color: Colors.white,),
                            const SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cricket World Cup  2023', style: GoogleFonts.albertSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),),
                                const SizedBox(height: 2.5,),
                                Text("Celebrate the World Cup with CricVerse!", style: GoogleFonts.albertSans(color: const Color(0xffFE00A8), fontWeight: FontWeight.w700, fontSize: 15),),
                                const SizedBox(height: 2.5,),
                                Text("Tap for World Cup Matches>>>", style: GoogleFonts.albertSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    const BannerAdWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Matches', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
                      ],
                    ), // matches row
                    const HomeScreenScoreList(),
                    const WicketHighlightScreen(),
                    const BannerAdWidget(),
                    const HighlightStoriesHome(),
                    const SizedBox(height: 10,),
                    TwitterTagsWidget(size),
                    const SizedBox(height: 20,),
                    // HomeScreenMemeButton(size), hiding until world cup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ICC Videos & Highlights', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const IccVideos())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xffFE00A8)
                            ),
                            child: Text('View All >>>', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),),
                          ),
                        )
                      ],
                    ), // icc videos row
                    const SizedBox(height: 0,),
                    SizedBox(
                      height: 150,
                      width: size.width,
                      child: const HomeScreenIccVideos(),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>const FantasyTips())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xffFE00A8),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events_outlined, color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text('Fantasy Tips', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),)
                              ],
                            ),
                          ),
                        ), // fantasy button
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>const Rankings())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xffFE00A8),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.trending_up, color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text('Rankings', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),)
                              ],
                            ),
                          ),
                        ), // ranking button
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>SubRedditScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xffFE00A8),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.groups, color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text('Social', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),)
                              ],
                            ),
                          ),
                        ) // social
                      ],
                    ), // buttons row
                    const SizedBox(height: 20,),
                    const BannerAdWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('News', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const NewsScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xffFE00A8)
                            ),
                            child: Text('View All >>>', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),),
                          ),
                        )
                      ],
                    ), // news row
                    const NewsHomeList()
                    //fantasy
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
