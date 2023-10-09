import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cricverse/providers/timer_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cricverse/api_service.dart';
import 'package:cricverse/models/score_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ScoreProvider extends ChangeNotifier{

  Map<String, dynamic> firstInningMap = {};
  Map<String, dynamic> secondInningMap = {};
  Map<String, dynamic> currentInning = {};
  List<dynamic>? firstInningBatsmen = [];
  List<dynamic>? firstInningBowlers = [];
  List<dynamic>? firstInningsWicket = [];
  List<dynamic>? firstInningFallOfWickets = [];
  List<dynamic>? secondInningBatsmen = [];
  List<dynamic>? secondInningBowlers = [];
  List<dynamic>? secondInningsWicket = [];
  List<dynamic>? secondInningFallOfWickets = [];
  Map<String, dynamic>? firstInningsTeam = {};
  Map<String, dynamic>? secondInningsTeam = {};
  List<Map<String, dynamic>>? ballComments = [];
  Map<String, dynamic> matchInfo = {};
  String currentSetInning = 'Inning 1';
  List<dynamic>? currentSetInningBatsmen = [];
  List<dynamic>? currentSetInningBowlers = [];
  String currentInningRuns = '';
  String currentInningWickets = '';
  String currentInningOver = '';
  String currentInningExtras = '';
  List<ScoreModel> homeScoreList = [];
  String currentSeriesId = '';
  String currentMatchId = '';
  final statusOrder = ["live", "result", "drinks", "stumps", "abandoned"];
  ApiService? apiService;
  double balanceAmount = 0;
  InterstitialAd? _interstitialAd;
  List<Map<String, dynamic>> squadPlayersList = [];
  bool squadEmpty = false;
  TimerProvider timerProvider = TimerProvider();

  void loadAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-6190421243004216/5251016233',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  // void fetchCoins()async{
  //   double points = timerProvider.secondsUsed/60;
  //   balanceAmount = points/100; // balance in inr
  //   notifyListeners();
  // }

  String calculateOver(int balls){
    int overs = balls ~/ 6; // Calculate the number of overs
    int remainingBalls = balls % 6; // Calculate the remaining balls
    return '$overs.$remainingBalls';
  }

  void handleInningChange(){
    if(currentSetInning=='Inning 1'){
      currentSetInning = 'Inning 2';
      currentSetInningBatsmen = secondInningBatsmen;
      currentSetInningBowlers = secondInningBowlers;
      currentInning = secondInningMap;
      // int ball =
    }else{
      currentSetInning = 'Inning 1';
      currentSetInningBatsmen = firstInningBatsmen;
      currentSetInningBowlers = firstInningBowlers;
      currentInning = firstInningMap;
    }
    notifyListeners();
  }

  DateTime currentDate = DateTime.now();
  int calculateSortOrder(ScoreModel scoreModel) {
    final DateTime matchStartTime = DateTime.parse(scoreModel.startTime!);

    // Check if the match is live
    if (scoreModel.status!.toLowerCase() == 'live') {
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

  void fetchLiveScores()async{
    apiService = ApiService('https://hs-consumer-api.espncricinfo.com/v1/pages/matches/current?lang=en&latest=true', 10);
    // var response = await http.get(Uri.parse('https://hs-consumer-api.espncricinfo.com/v1/pages/matches/current?lang=en&latest=true'));
    // var jsonBody = json.decode(response.body);
    apiService!.stream.listen((jsonBody) {
      homeScoreList.clear();
      for(var v in jsonBody['matches']){
        if(v['internationalClassId']!=null&&v['dayType']!='MULTI'){
          ScoreModel scoreModel = ScoreModel(
            matchObjectId: v['objectId'].toString(), seriesObjectId: v['series']['objectId'].toString(),
            title: v['title'], status: v['status'], format: v['format'], dayType: v['dayType'], endDate: v['endDate'].toString(),
            floodlit: v['floodlit'], isCancelled: v['isCancelled'], isSuperOver: v['isSuperOver'], liveOvers: v['liveOvers'].toString(),
            seriesName: v['series']['name'], stadium: v['ground']['name'], stadiumImage: v['ground']['url'],
            stage: v['stage'], state: v['state'], statusText: v['statusText'], team1FlagUrl: v['teams'][0]['team']['imageUrl'],
            team1Name: v['teams'][0]['team']['abbreviation'], team1Score: v['teams'][0]['score'], team1ScoreInfo: v['teams'][0]['scoreInfo']??'',
            team2FlagUrl: v['teams'][1]['team']['imageUrl'], team2ScoreInfo: v['teams'][1]['scoreInfo']??'',
            team2Name: v['teams'][1]['team']['abbreviation'], team2Score: v['teams'][1]['score'], startTime: v['startTime']
          );
          homeScoreList.add(scoreModel);
        }
        homeScoreList.sort((a, b) => calculateSortOrder(a).compareTo(calculateSortOrder(b)));
      }
      notifyListeners();
    });
  }

  void fetchScoreCard()async{
    apiService = ApiService('https://hs-consumer-api.espncricinfo.com/v1/pages/match/home?lang=en&seriesId=$currentSeriesId&matchId=$currentMatchId', 10);
    // var response = await http.get(Uri.parse('https://hs-consumer-api.espncricinfo.com/v1/pages/match/home?lang=en&seriesId=1392778&matchId=1392783'));
    apiService!.stream.listen((jsonObject) {
      var contentObject = jsonObject['content'] as Map<String, dynamic>;
      matchInfo = jsonObject['match'];
      if (contentObject['innings'] != null) {
        firstInningMap = contentObject['innings'][0];
        ballComments = contentObject['innings'][0]['recentBallCommentary'];
        firstInningFallOfWickets = contentObject['innings'] != null ? contentObject['innings'][0]['inningFallOfWickets'] : [];
        firstInningsTeam = contentObject['innings'][0]['team'];
        firstInningsWicket = contentObject['innings'][0]['inningWickets'];
        firstInningBatsmen = contentObject['innings'][0]['inningBatsmen'];
        firstInningBowlers = contentObject['innings'][0]['inningBowlers'];
        if(contentObject['innings'][1] != null){
          secondInningMap = contentObject['innings'][1];
          secondInningFallOfWickets = contentObject['innings'][1]['inningFallOfWickets'] ?? [];
          secondInningsTeam = contentObject['innings'][1]['team'];
          secondInningsWicket = contentObject['innings'][1]['inningWickets'];
          secondInningBatsmen = contentObject['innings'][1]['inningBatsmen'];
          secondInningBowlers = contentObject['innings'][1]['inningBowlers'];
        }
      }
      currentSetInningBatsmen = firstInningBatsmen;
      currentSetInningBowlers = firstInningBowlers;
      currentInning = firstInningMap;
      notifyListeners();
    });
  }
  
  void fetchTeamSquad(url)async{
    var response = await http.get(Uri.parse(url));
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['content']['matchPlayers']['teamPlayers']){
      Map<String, dynamic> mapToAdd = {v['team']['name']:v['players']};
      squadPlayersList.add(mapToAdd);
    }
    if(squadPlayersList.isEmpty){
      squadEmpty = true;
    }else{
      squadEmpty = false;
    }
    notifyListeners();
  }

  void takeScreenShotAndShare(GlobalKey itemKey)async{
    RenderRepaintBoundary boundary =
    itemKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await Future.delayed(const Duration(seconds: 2));
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();
    var directory = await getApplicationCacheDirectory();
    File file = File('${directory.path}/ss-to-share.png');
    await file.writeAsBytes(uint8List);
    Share.shareFiles(['${directory.path}/ss-to-share.png']);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    apiService!.dispose();
  }
}