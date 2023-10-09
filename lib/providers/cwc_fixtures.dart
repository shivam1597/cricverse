import 'dart:convert';
import 'dart:io';
import 'package:cricverse/models/icc_videos_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
class WorldCupFixtureProvider extends ChangeNotifier {

  List<dynamic> fixtures = [];
  List<IccVideosModel> iccVideosList = [];
  String selectedCountry = '';
  int pageCount = 0;
  bool loadingMore = false;
  String selectedCountryReference = '';
  String downloadVideoUrl = '';
  String downloadVideoName = '';
  List<String> savedVideos = [];
  bool downloadingProgress = false;
  bool permissionAsked = false;
  List<Map<String?, String?>> weatherReport = [];
  double weatherAnimatedContainerHeight = 210;
  Map<String, Map<String, String>> venueIdsForWeather = {
    'Ahmedabad':{'Ahmedabad':'202438'},
    'Bengaluru':{'Bengaluru': '204108'},
    'Chennai':{'Chennai': '206671'},
    'Delhi':{'Delhi': '202396'},
    'Dharamsala':{'Dharamshala': '3018757'},
    'Guwahati':{'Guwahati': '186893'},
    'Hyderabad':{'Hyderabad': '202190'},
    'Kolkata':{'Kolkata': '206690'},
    'Lucknow':{'Lucknow': '206678'},
    'Mumbai':{'Mumbai': '204842'},
    'Pune':{'Pune': '204848'},
  };

  Map<String, String> countryId = {
    'India': '14',
    'England': '11',
    'Afghanistan': '17',
    'Australia': '15',
    'Bangladesh': '22',
    'New Zealand': '16',
    'Pakistan': '20',
    'South Africa': '19',
    'Netherlands': '68',
    'Sri Lanka': '13'
  };

  InterstitialAd? _interstitialAd;

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

  Future<void> showInterstitialAd() async {
    _interstitialAd!.show();
  }

  void getFixtures() async {
    final box = await Hive.openBox('myBox');
    if (box.containsKey('cwcFixtures')) {
      fixtures = box.get('cwcFixtures');
    } else {
      var response = await http.get(
          Uri.parse('https://www.cricketworldcup.com/fixtures'));
      final document = html_parser.parse(response.body);
      final matchItems = document.querySelectorAll('.match-block__body');
      for (final matchItem in matchItems) {
        final teamNames = matchItem.querySelectorAll('.match-block__team-name');
        final stadiumName = matchItem.querySelector('.match-block__venue-name');
        final startDateElement = matchItem.querySelector(
            'time[class="match-block__date-user js-date"]')!
            .attributes['data-startdate']; //.attributes['data-startDate'];
        final localDateElement = matchItem.querySelector(
            '.match-block__date-local');
        final href = matchItem
            .getElementsByClassName('btn btn--mc')
            .first
            .attributes['href'];
        // Extract text from HTML elements
        final team1Name = teamNames[0].text;
        final team2Name = teamNames[1].text;
        final stadium = stadiumName!.text;
        final startDate = startDateElement;
        final localDate = localDateElement!.text;

        // Create a MatchInfo object and add it to the list
        final matchInfo = {
          'team1Name': team1Name,
          'team2Name': team2Name,
          'stadium': stadium,
          'startDate': startDate,
          'localDate': localDate.trim(),
          'href': 'https://www.cricketworldcup.com$href'
        };
        fixtures.add(matchInfo);
      }
      box.put('cwcFixtures', fixtures);
      fixtures = box.get('cwcFixtures');
    }
    notifyListeners();
  }

  void handlePageCount()async{
    loadingMore = !loadingMore;
    pageCount++;
    notifyListeners();
    await fetchIccVideos();
    loadingMore = !loadingMore;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getRankings(String url) async {
    Map<String, dynamic> matchCentreMap = {};
    var response = await http.get(Uri.parse(url));
    // Parse the HTML content
    final document = html_parser.parse(response.body);

    // Find the relevant elements based on the HTML structure
    final teamComparisonRows = document.querySelectorAll(
        '.mc-team-comparison__row');
    matchCentreMap['team1Name'] = teamComparisonRows[2]
        .getElementsByClassName('mc-team-comparison__team-name')
        .first
        .text;
    matchCentreMap['team2Name'] = teamComparisonRows[2]
        .getElementsByClassName('mc-team-comparison__team-name')
        .last
        .text;
    matchCentreMap['team1cwcCount'] = teamComparisonRows[4]
        .getElementsByClassName('mc-team-comparison__team-stat ')
        .first
        .text;
    matchCentreMap['team2cwcCount'] = teamComparisonRows[4]
        .getElementsByClassName('mc-team-comparison__team-stat ')
        .last
        .text;
    List<Map<String, String>> team1PreviousMatches = [];
    List<Map<String, String>> team2PreviousMatches = [];
    for (int i = 7; i <= 11; i++) {
      final team1MapToAdd = {
        'opponentName': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__team-name')
            .first
            .text,
        'matchResult': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__recent-form')
            .first
            .attributes['data-content'].toString(),
        'matchResultLong': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__summary')
            .first
            .text
      };
      final team2MapToAdd = {
        'opponentName': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__team-name')
            .last
            .text,
        'matchResult': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__recent-form')
            .last
            .attributes['data-content'].toString(),
        'matchResultLong': teamComparisonRows[i]
            .querySelectorAll('.mc-team-comparison__summary')
            .last
            .text
      };
      team1PreviousMatches.add(team1MapToAdd);
      team2PreviousMatches.add(team2MapToAdd);
    }
    matchCentreMap['team1Results'] = team1PreviousMatches;
    matchCentreMap['team2Results'] = team2PreviousMatches;
    return matchCentreMap;
  }

  void handleCountryChange(String countryName)async{
    // 'CRICKET_TEAM:'
    iccVideosList.clear();
    if (countryName != selectedCountry) {
      selectedCountry = countryName;
      selectedCountryReference = 'CRICKET_TEAM:${countryId[countryName]}';
    } else {
      selectedCountry = '';
      selectedCountryReference = '';
    }
    notifyListeners();
    await fetchIccVideos();
  }

  Future<void> fetchIccVideos()async{
    var response = await http.get(Uri.parse('https://content-icc.pulselive.com/content/icc/video/en/?page=$pageCount&pageSize=10&onlyRestrictedContent=false&references=$selectedCountryReference&tagNames=Cricket%20World%20Cup'));
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['content']){
      IccVideosModel iccVideosModel = IccVideosModel(title: v['title'], duration: v['duration'].toString(),
        description: v['description'], thumbnailUrl: v['thumbnailUrl'], mediaId: v['mediaId'], titleUrlSegment: v['titleUrlSegment']
      );
      iccVideosList.add(iccVideosModel);
    }
    notifyListeners();
  }

  showProgressDialog(context){
    showDialog(
        context: context,
        builder: (context){
          return const AlertDialog(
            backgroundColor: Colors.transparent,
            content: Center(
              child: CircularProgressIndicator(color: Color(0xff310072),),
            ),
          );
        }
    );
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

  Future<void> downloadVideo() async {
    if(!downloadingProgress){
      downloadingProgress = !downloadingProgress;
      notifyListeners();
      if(!await Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').exists()){
        await Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').create();
      }
      File file = File('/storage/emulated/0/Download/CricVerse/CWCVideos/$downloadVideoName.mp4');
      var response = await http.get(Uri.parse(downloadVideoUrl));
      await file.writeAsBytes(response.bodyBytes);
      Fluttertoast.showToast(msg: 'Video saved');
      loadAd();
      showInterstitialAd();
      downloadingProgress = !downloadingProgress;
      notifyListeners();
    }else{
      Fluttertoast.showToast(msg: 'Please wait until the download completes.');
    }
  }

  void fetchDownloadedVideos()async{
    if(await Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').exists()){
      final videosList = Directory('/storage/emulated/0/Download/CricVerse/CWCVideos/').listSync();
      for(var v in videosList){
        if(v.path.contains('.mp4')){
          savedVideos.add(v.path.split('/').last.replaceAll('.mp4', ''));
        }
      }
      notifyListeners();
    }
  }

  void handleDownloadUrl(String url, String videoTitle){
    downloadVideoUrl = url;
    downloadVideoName = videoTitle;
    notifyListeners();
  }

  void handleWeatherContainerHeightChange(context, bool isSharing){
    if(weatherAnimatedContainerHeight == MediaQuery.of(context).size.height){
      weatherAnimatedContainerHeight = 210;
    }else if(isSharing&&weatherAnimatedContainerHeight==210){
      weatherAnimatedContainerHeight = MediaQuery.of(context).size.height;
    }
    notifyListeners();
  }

  void fetchWeather(String cityId, String cityName)async{
    final response = await http.get(Uri.parse('https://www.accuweather.com/en/in/$cityName/$cityId/hourly-weather-forecast/$cityId'));
    final htmlDocument = html_parser.parse(response.body);
    final allWeatherCards = htmlDocument.getElementsByClassName('hourly-detailed-card-header ');
    for(var document in allWeatherCards){
      final hour = document.querySelector('.date div')?.text;
      final temperature = document.querySelector('.temp.metric')?.text;
      final svgIcon = document.getElementsByClassName('icon').first.attributes['data-src'];
      final precip = document.querySelector('.precip')?.text;
      final phrase = document.querySelector('.phrase')?.text;
      final wind = document.getElementsByClassName('value').first.text;
      Map<String?, String?> mapToAdd = {
        'hour':hour!.trim(),
        'temperature':temperature!.trim(),
        'icon':'https://www.accuweather.com${svgIcon!.trim()}',
        'wind':wind!.trim(),
        'precipitation':precip!.trim(),
        'phrase':phrase!.trim()
      };
      weatherReport.add(mapToAdd);
    }
    notifyListeners();
  }

  void takeScreenShotAndShare(GlobalKey itemKey, String message,{context})async{
    showLoadingProgress(context);
    RenderRepaintBoundary boundary =
    itemKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await Future.delayed(const Duration(seconds: 2));
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();
    var directory = await getApplicationCacheDirectory();
    File file = File('${directory.path}/ss-to-share.png');
    await file.writeAsBytes(uint8List);
    Navigator.pop(context);
    Share.shareFiles(['${directory.path}/ss-to-share.png'], text: message);
  }

  void showLoadingProgress(context){
    showDialog(
      context: context,
      builder: (context){
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: CircularProgressIndicator(
              color: Color(0xffFE00A8),
            ),
          ),
        );
      }
    );
  }

}