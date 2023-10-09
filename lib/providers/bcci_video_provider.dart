import 'dart:convert';
import 'dart:io';
import 'package:cricverse/models/icc_videos_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'ads_provider.dart';
class BcciVideoProvider extends ChangeNotifier{
  bool loadingMore = false;
  bool downloadingProgress = false;
  String downloadVideoUrl = '';
  String downloadVideoName = '';
  int pageCount = 0;
  List<IccVideosModel> videosList = [];
  List<String> savedVideos = [];
  List<String> videosCategory = ['Latest', 'Highlights'];
  List<String> formats = ['ODIs', 'Tests', 'T20Is', 'All'];
  String selectedFormat = 'all';
  String selectedCategory = 'latest';

  void handleSelection({String? category, String? format}){
    if(category!=null){
      selectedCategory = category;
    }
    if(format!=null){
      selectedFormat = format;
    }
    notifyListeners();
    videosList.clear();
    fetchVideos();
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

  Future<String> getVideoUrl(String accountId, String mediaId)async{
    String url = 'https://edge.api.brightcove.com/playback/v1/accounts/$accountId/videos/$mediaId';
    String videoSourceUrl = '';
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json;pk=BCpkADawqM1HAZVeYx6iS1Oqr12hCyvC8IGQSuDaTfRbJK_pYnfZoexbte9KOmx0moKY-9kcDMp-YPmJaBTdmZi_SYqnWJs-qANYeAOvpjncLe86hNPaG5XEdSCTTFk-ktvWxZhbK4Yel9UX"
    });
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['sources']){
      if(v['container']!=null){
        videoSourceUrl = v['src'];
      }
    }
    return videoSourceUrl;
  }

  Future<void> downloadVideo(context) async {
    if(!downloadingProgress){
      final adsProvider = Provider.of<AdsProvider>(context, listen: false);
      adsProvider.loadAd();
      downloadingProgress = !downloadingProgress;
      notifyListeners();
      if(!await Directory('/storage/emulated/0/Download/CricVerse/BcciVideos/').exists()){
        await Directory('/storage/emulated/0/Download/CricVerse/BcciVideos/').create();
      }
      File file = File('/storage/emulated/0/Download/CricVerse/BcciVideos/$downloadVideoName.mp4');
      var response = await http.get(Uri.parse(downloadVideoUrl));
      await file.writeAsBytes(response.bodyBytes);
      Fluttertoast.showToast(msg: 'Video saved');
      downloadingProgress = !downloadingProgress;
      adsProvider.showInterstitialAd();
      notifyListeners();
    }else{
      Fluttertoast.showToast(msg: 'Please wait until the download completes.');
    }
  }

  void fetchDownloadedVideos()async{
    if(await Directory('/storage/emulated/0/Download/CricVerse/BcciVideos/').exists()){
      final videosList = Directory('/storage/emulated/0/Download/CricVerse/BcciVideos/').listSync();
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

  Future<void> fetchVideos()async{
    var response = await http.post(Uri.parse('https://www.bcci.tv/showMoreVideos'),
      body: {
        'type': selectedCategory,
        'page': '1',
        'year': '2023',
        'matchformat': selectedFormat.toLowerCase(),
        '_token': 'G5EsGMX074ABgjJQ2dex0CXG66dOHjfh9HpjPPFd'
      }
    );
    var jsonObject = json.decode(response.body);
    print(jsonObject);
    for(var v in jsonObject['response']){
      IccVideosModel iccVideosModel = IccVideosModel(titleUrlSegment: v['titleUrlSegment'], title: v['title'], thumbnailUrl: v['thumbnail_image'],
        accountId: v['accountId'].toString(), mediaId: v['mediaId'].toString(), duration: v['duration'].toString(), publishedDate: v['created_date'].toString(),
        viewsCount: v['views_count'].toString()
      );
      videosList.add(iccVideosModel);
    }
    notifyListeners();
  }

  void handlePageCount()async{
    loadingMore = !loadingMore;
    pageCount++;
    notifyListeners();
    await fetchVideos();
    loadingMore = !loadingMore;
    notifyListeners();
  }
}