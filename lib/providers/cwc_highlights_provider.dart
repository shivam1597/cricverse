import 'dart:convert';
import 'dart:io';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CricketHighlightProvider extends ChangeNotifier{

  List<Map<String, dynamic>> worldCupMatches = [];
  Map<String, String> teamPlayersMap = {};
  String messageToShow = '';
  List<String> outPlayersId = [];
  List<Map<String?, String?>> videosMetaData = [];
  String downloadUrl = '';
  String downloadVideoName = '';
  bool downloadingProgress = false;
  Map<Object?, Object?> ampStories = {};
  AdsProvider adsProvider = AdsProvider();
  int? downloadingVideoIndex;
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  void fetchMatches()async{
    DateTime currentDate = DateTime.now();
    DateTime oneDayBeforeDate = currentDate.subtract(const Duration(days: 2));
    String beforeDate = DateFormat('yyyy-MM-dd').format(oneDayBeforeDate);
    String todayDate = DateFormat('yyyy-MM-dd').format(currentDate);
    var response = await http.get(Uri.parse('https://cricketapi-icc.pulselive.com/fixtures?tournamentTypes=I%2CWI&startDate=$beforeDate&endDate=$todayDate&pageSize=100'),
        headers: {'Account':'ICC'}
    );
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['content']){
      if(v['tournamentLabel'].toString().contains('Cricket World Cup')&&v['scheduleEntry']['team1']['innings']!=null&&v['scheduleEntry']['team2']['innings']!=null){
        if(v['scheduleEntry']['matchState']=='C'||v['scheduleEntry']['matchState']=='L'
            ||v['scheduleEntry']['team1']['innings'][0]['wkts']>0||v['scheduleEntry']['team2']['innings'][0]['wkts']>0){
          String matchId = v['scheduleEntry']['matchId']['id'].toString();
          String team1 = v['scheduleEntry']['team1']['team']['fullName'];
          String team2 = v['scheduleEntry']['team2']['team']['fullName'];
          String team1Abbreviation = v['scheduleEntry']['team1']['team']['abbreviation'];
          String team2Abbreviation = v['scheduleEntry']['team2']['team']['abbreviation'];
          var mapToAdd = {
            'team1':team1,
            'team2':team2,
            'matchId':matchId,
            'team1Abbr':team1Abbreviation,
            'team2Abbr':team2Abbreviation
          };
          worldCupMatches.add(mapToAdd);
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchMatchScoreCard(String matchId)async{
    messageToShow = 'Fetching fallen wickets';
    outPlayersId.clear();
    videosMetaData.clear();
    teamPlayersMap.clear();
    var response = await http.get(Uri.parse('https://api.icc.cdp.pulselive.com/fixtures/$matchId/scoring'));
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['matchInfo']['teams'][0]['players']){
      teamPlayersMap[v['id'].toString()]=v['fullName'];
    }
    for(var v in jsonObject['matchInfo']['teams'][1]['players']){
      teamPlayersMap[v['id'].toString()]=v['fullName'];
    }
    for(var v in jsonObject['innings'][0]['scorecard']['battingStats']){
      if(v['mod']!=null&&v['mod']['isOut']){
        outPlayersId.add(v['playerId'].toString());
      }
      // var mapToAdd = {
      //   'playerId':v['playerId'],
      //   'run':v['r'].toString(),
      //   'ball':v['b'].toString(),
      //   'sr':v['sr'].toString(),
      //   '4s':v['4s'].toString(),
      //   '6s':v['6s'].toString(),
      //   'text':v['mod']!=null?v['mod']['text']:null,
      //   'isOut':v['mod']!=null?v['mod']['isOut']:null
      // };
    }
    for(var v in jsonObject['innings'][1]['scorecard']['battingStats']){
      if(v['mod']!=null&&v['mod']['isOut']){
        outPlayersId.add(v['playerId'].toString());
      }
      // var mapToAdd = {
      //   'playerId':v['playerId'],
      //   'run':v['r'].toString(),
      //   'ball':v['b'].toString(),
      //   'sr':v['sr'].toString(),
      //   '4s':v['4s'].toString(),
      //   '6s':v['6s'].toString(),
      //   'text':v['mod']!=null?v['mod']['text']:null,
      //   'isOut':v['mod']!=null?v['mod']['isOut']:null
      // };
    }
    await fetchWicketVideo(matchId);
    notifyListeners();
  }

  Future<void> fetchWicketVideo(String matchId)async{
    messageToShow = 'Fetching videos...';
    notifyListeners();
    for(String id in outPlayersId){
      Map<String?, String?> map = await getThumbnail(id, matchId);
      videosMetaData.add(map);
    }
  }

  Future<Map<String?,String?>> getThumbnail(String playerId, String matchId)async{
    var response = await http.get(Uri.parse('https://content-icc.pulselive.com/content/icc/video/en/?references=CRICKET_MATCH:$matchId,CRICKET_PLAYER:$playerId&tagNames=wicket'));
    var jsonObject = json.decode(response.body);
    String? thumbnail = jsonObject['content'].length>0? jsonObject['content'][0]['additionalInfo']['bc_thumbnail_url']:null;
    String? videoId = jsonObject['content'].length>0?jsonObject['content'][0]['mediaId']:null;
    String? title = jsonObject['content'].length>0?jsonObject['content'][0]['title']:null;
    return {
      'title':title,
      'thumbnail':thumbnail,
      'videoId':videoId
    };
  }

  Future<String> getVideoUrl(String mediaId)async{
    String url = 'https://edge.api.brightcove.com/playback/v1/accounts/3910869736001/videos/$mediaId';
    String videoSourceUrl = '';
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json;pk=BCpkADawqM3C-aBtIVj85VHfAxqkr6IxNihzWVyjeBAAv9-o5MmGIWosk5qcS96gCstfgZ7GLiTXJVhxwAneqgqRfAocpjkjLZnFMcR6fcAbI3fmd_Qxu3mA1BRlE03pKbRufCCUGFKDPYeX"
    });
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['sources']){
      if(v['container']!=null){
        videoSourceUrl = v['src'];
      }
    }
    return videoSourceUrl;
  }

  Future<void> downloadVideo(int videoIndex) async {
    adsProvider.loadAd();
    if(!downloadingProgress){
      downloadingVideoIndex = videoIndex;
      downloadingProgress = !downloadingProgress;
      notifyListeners();
      if(!await Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').exists()){
        await Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').create();
      }
      File file = File('/storage/emulated/0/Download/CricVerse/CWCVideos/$downloadVideoName.mp4');
      var response = await http.get(Uri.parse(downloadUrl));
      await file.writeAsBytes(response.bodyBytes);
      Fluttertoast.showToast(msg: 'Video saved');
      adsProvider.showInterstitialAd();
      downloadingProgress = !downloadingProgress;
      notifyListeners();
    }else{
      Fluttertoast.showToast(msg: 'Please wait until the download completes.');
    }
  }

  void showProgressDialog(context){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              backgroundColor: Colors.transparent,
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xffFE00A8),),
                    const SizedBox(height: 20,),
                    Text(messageToShow, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),)
                  ],
                ),
              )
          );
        }
    );
  }
  
  void fetchStoriesList()async{
    DatabaseReference databaseReference = firebaseDatabase.ref();
    var dataEvent = await databaseReference.child('amp_stories').once();
    Map<Object?, Object?> storiesData = dataEvent.snapshot.value as Map<Object?, Object?>;
    List<MapEntry<Object?, Object?>> sortedMap = storiesData.entries.toList()..sort((a,b){
      final value1 = int.parse(a.key.toString());
      final value2 = int.parse(b.key.toString());
      return value2.compareTo(value1);
    });
    ampStories = Map.fromEntries(sortedMap);
    notifyListeners();
  }

}