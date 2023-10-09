import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/bcci_video_provider.dart';
import 'package:cricverse/providers/coins_provider.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:cricverse/providers/cwc_highlights_provider.dart';
import 'package:cricverse/providers/cwc_tickets_provider.dart';
import 'package:cricverse/providers/meme_templates_provider.dart';
import 'package:cricverse/providers/news_provider.dart';
import 'package:cricverse/providers/ranking_provider.dart';
import 'package:cricverse/providers/reddit_provider.dart';
import 'package:cricverse/providers/rewarded_ads_provider.dart';
import 'package:cricverse/providers/score_providers.dart';
import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:cricverse/providers/timer_provider.dart';
import 'package:cricverse/providers/twitter_provider.dart';
import 'package:cricverse/providers/user_details_provider.dart';
import 'package:cricverse/scorecard_widgets/parent_score_card_tab.dart';
import 'package:cricverse/scorecard_widgets/team_squads.dart';
import 'package:cricverse/sub_home_screens/login_screen.dart';
import 'package:cricverse/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

//https://imgflip.com/memesearch?q=cricket
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('cric_verse_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('myBox');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=> ScoreProvider()),
        ChangeNotifierProvider(create: (context)=> WorldCupFixtureProvider()),
        ChangeNotifierProvider(create: (context)=> RedditProvider()),
        ChangeNotifierProvider(create: (context)=> NewsProvider()),
        ChangeNotifierProvider(create: (context)=> RankingProvider()),
        ChangeNotifierProvider(create: (context)=> CoinsProvider()),
        ChangeNotifierProvider(create: (context)=> UserDetailsProvider()),
        ChangeNotifierProvider(create: (context)=> BcciVideoProvider()),
        ChangeNotifierProvider(create: (context)=> TimerProvider()),
        ChangeNotifierProvider(create: (context)=> CwcTicketProvider()),
        ChangeNotifierProvider(create: (context)=> MemeTemplateProvider()),
        ChangeNotifierProvider(create: (context)=> AdsProvider()),
        ChangeNotifierProvider(create: (context)=> TwitterProvider()),
        ChangeNotifierProvider(create: (context)=> CricketHighlightProvider()),
        ChangeNotifierProvider(create: (context)=> ScorecardsProvider()),
        ChangeNotifierProvider(create: (context)=> RewardedAdsProvider())
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScoreTest(),
      ),
    )
  );
}

//https://api.icc.cdp.pulselive.com/fixtures/{match_id}/scoring
// FE00A8 - purple or pink type
// 310072 - deep blue