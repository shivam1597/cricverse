import 'dart:async';
import 'dart:convert';
import 'package:cricverse/providers/news_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ScorecardsProvider extends ChangeNotifier{

  Map<String, dynamic> matchInfo = {};
  // like toss winner, status and more
  String? currentMatchId;
  String? tossWinner;
  String? tossWinnerChoice;
  List<String> teamNames = [];
  List<dynamic> battingOrder = [];
  List<String> teamAbbreviations = [];
  List<String> captainIds = [];
  List<String> wicketKeeperIds = [];
  Map<String, String> playersMap = {};
  Map<String, dynamic> venueInfo = {};
  Map<String, dynamic> currentBowlerSpell = {};
  Map<String, dynamic> currentPartnership = {};
  List<String> currentBatsmen = [];
  List<dynamic> innings = [];
  final List<String> battingHeaderList = ['Player', 'R', 'B', "4's", "6's", 'S/R'];
  List<String> bowlingHeaderList = ['Player', 'O', 'M', 'R', 'W', 'Econ', 'Dots'];
  bool hasToCallApi = true;
  int tabsIndex = 0;
  List<dynamic> commentaries = [];
  bool commentaryState = false;
  bool hasToCallCommentaryApi = false;
  FlutterTts flutterTts = FlutterTts();
  NewsProvider newsProvider = NewsProvider();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void setCurrentMatchId(String matchId){
    currentMatchId = matchId;
    notifyListeners();
  }

  void handleTabIndex(int index){
    tabsIndex = index;
    notifyListeners();
    if(index==0){
      hasToCallApi = true;
      if(!commentaryState){
        hasToCallCommentaryApi = false;
      }
      fetchScores();
    }else if(index==1){
      if(!hasToCallCommentaryApi){
        hasToCallCommentaryApi = true;
      }
      hasToCallApi = false;
      fetchCommentary();
    } else if(index==2){
      hasToCallApi = false;
      if(!commentaryState){
        hasToCallCommentaryApi = false;
      }
      notifyListeners();
    }
  }

  void handleCommentaryButtonTap()async{
    commentaryState = !commentaryState;
    if(commentaryState){
      hasToCallCommentaryApi = true;
      await showTTSRunningNotification();
      fetchCommentary();
    }else{
      hasToCallCommentaryApi = false;
      await flutterTts.stop();
      await flutterLocalNotificationsPlugin.cancelAll();
    }
    notifyListeners();
  }

  void fetchScores()async{
    while(hasToCallApi){
      playersMap.clear();
      currentBatsmen.clear();
      teamNames.clear();
      teamAbbreviations.clear();
      captainIds.clear();
      wicketKeeperIds.clear();
      battingOrder.clear();
      var response = await http.get(Uri.parse('https://cricketapi-icc.pulselive.com/fixtures/$currentMatchId/scoring'), headers: {'Account':'ICC'});
      var jsonObject = json.decode(response.body);
      var matchInfoJson = jsonObject['matchInfo'];
      var currentStatusJson = jsonObject['currentState'];
      Map<String, dynamic> matchAdditionalInfo = matchInfoJson['additionalInfo'];
      battingOrder = matchInfoJson['battingOrder'];
      if(matchAdditionalInfo.isNotEmpty){
        matchInfo['tossWinner'] = matchAdditionalInfo['toss.winner'];
        matchInfo['tossWinnerChoice'] = matchAdditionalInfo['toss.elected'];
      }
      int i = 0;
      for(var v in matchInfoJson['teams']){
        if(i==0){ // for team 1
          teamNames.add(v['team']['fullName']);
          teamAbbreviations.add(v['team']['abbreviation']);
          captainIds.add(v['captain']['id'].toString());
          wicketKeeperIds.add(v['wicketKeeper']['id'].toString());
          // team1Name = v['team']['fullName'];
          Map<String, String> playerIdMapToAdd = {};
          for(var player in v['players']){
            playersMap[player['id'].toString()] = player['fullName'];
            // playersIdMaps.add(playerIdMapToAdd);
          }
        }
        if(i==1){ // for team 1
          // team2Name = v['team']['fullName'];
          teamNames.add(v['team']['fullName']);
          teamAbbreviations.add(v['team']['abbreviation']);
          captainIds.add(v['captain']['id'].toString());
          wicketKeeperIds.add(v['wicketKeeper']['id'].toString());
          Map<String, String> playerIdMapToAdd = {};
          for(var player in v['players']){
            playersMap[player['id'].toString()] = player['fullName'];
            // playersIdMaps.add(playerIdMapToAdd);
          }
        }
        i++;
      }
      venueInfo = matchInfoJson['venue'];
      matchInfo['matchDate'] = matchInfoJson['matchDate'];
      matchInfo['description'] = matchInfoJson['description'];
      matchInfo['tournamentLabel'] = matchInfoJson['tournamentLabel'];
      matchInfo['matchBroadcast'] = matchInfoJson['matchBroadcast'];
      matchInfo['matchState'] = matchInfoJson['matchState']; // live or not
      matchInfo['matchStatusText'] = matchInfoJson['matchStatus']!=null?matchInfoJson['matchStatus']['text']:'';
      currentBatsmen.add(currentStatusJson['facingBatsman'].toString()); // at index 0, batsman on strike
      currentBatsmen.add(currentStatusJson['nonFacingBatsman'].toString()); // at index 1, batsman non strike
      currentBowlerSpell = currentStatusJson['currentBowlerCurrentSpell'];
      currentPartnership = currentStatusJson['partnership'];
      innings = jsonObject['innings'];
      if(battingOrder.first==1){
        teamNames = teamNames.reversed.toList();
        teamAbbreviations = teamAbbreviations.reversed.toList();
      }
      notifyListeners();
      await Future.delayed(const Duration(seconds: 8));
    }
  }

  void fetchCommentary()async{
    final box = await Hive.openBox('myBox');
    while(hasToCallCommentaryApi){
      commentaries.clear();
      var response = await http.get(Uri.parse('https://api.icc.cdp.pulselive.com/commentary/ICC/$currentMatchId/EN/?direction=descending&maxResults=30'));
      var jsonObject = await json.decode(response.body);
      commentaries = jsonObject['commentaries']['content'];
      if(commentaryState&&commentaries.first['ballDetails']!=null){
        String textToSpeak = '';
        if(commentaries.first['ballDetails']!=null){
          textToSpeak = commentaries.first['ballDetails']['message'];
        }else{
          textToSpeak = 'End of over ${commentaries.first!['over']}. ${commentaries.first['details']['team']['fullName']} require ${commentaries.first['details']['requiredRuns']} off ${commentaries.first['inningsMaxBalls']-commentaries.first['inningsBalls']}';
        }
        if(box.get('lastCommentary')!=commentaries.first['ballDetails']['message']){
          flutterTts.speak(commentaries.first['ballDetails']['message']);
          box.put('lastCommentary', commentaries.first['ballDetails']['message']);
        }
      }
      notifyListeners();
      await Future.delayed(const Duration(seconds: 7));
    }
  }

  setStateNotification(){
    hasToCallCommentaryApi = false;
    commentaryState = false;
    flutterTts.stop();
    notifyListeners();
  }

  static notificationTapBackground(NotificationResponse notificationResponse, setStateNotification){
    setStateNotification();
  }

  Future<void> showTTSRunningNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('cric_verse_icon');
    InitializationSettings initializationSettings = const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (notificationResponse)=> notificationTapBackground(notificationResponse, setStateNotification()));
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails(
      '0',
      'Flutter TTS Service',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      ongoing: true, // This makes the notification sticky
    );
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      '\nLive Commentary is in progress.',
      'Tap to stop.',
      platformChannelSpecifics,
    );
  }

}