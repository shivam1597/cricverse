import 'dart:convert';
import 'dart:io';
import 'package:cricverse/my_video_player.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:cricverse/models/reddit_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class RedditProvider extends ChangeNotifier{

  List<RedditModel>subredditPostList = [];
  List<RedditModel>detailsPageList = [];
  RedditModel detailsPageModel = RedditModel();
  List<String> subredditUrls = ['https://www.reddit.com/r/Cricket/.json?after=', 'https://www.reddit.com/r/CricketShitpost/.json?after='];
  int subredditIndex = 0;
  String detailedPostUrl = '';
  String afterCursor = '';
  bool loadingProgress = false;

  //https://www.reddit.com/r/Cricket/
  //https://www.reddit.com/r/CricketShitpost/
  //https://hs-consumer-api.espncricinfo.com/v1/pages/story/news?lang=en -> cricket news
  //series-slug+seriesObjectId+slug(in match meta)+objectId(in match-meta)
  //https://hs-consumer-api.espncricinfo.com/v1/pages/video?country=in -> cricket videos
  void handleUrlChange(){
    if(subredditIndex==0){
      subredditIndex = 1;
    }
    else{
      subredditIndex = 0;
    }
    notifyListeners();
    fetchSubreddit();
  }

  void handlePostDetailUrl(String url, RedditModel redditModel){
    detailedPostUrl = 'https://www.reddit.com$url.json';
    detailsPageModel = redditModel;
    notifyListeners();
  }

  void fetchSubreddit()async{
    loadingProgress = true;
    var response = await http.get(Uri.parse('${subredditUrls[subredditIndex]}$afterCursor'));
    notifyListeners();
    var jsonObject = json.decode(response.body);
    String sourceUrl = 'https://sd.redditsave.com/download.php?permalink=https://reddit.com/&video_url=';
    afterCursor = jsonObject['data']['after'];
    for(var v in jsonObject['data']['children']){
      Map<String, dynamic> objectToFetch = v['data'];
      if(!objectToFetch['over_18']){
        final String videoUrl = objectToFetch['is_video']?objectToFetch['media']['reddit_video']['fallback_url'].toString().replaceAllMapped(RegExp(r'DASH_\d+'), (match){
          return 'DASH_240';
        }):'';
        final String audioUrl = objectToFetch['is_video']?videoUrl.replaceAllMapped(RegExp(r'DASH_\d+'), (match) {
          return 'DASH_audio'; // Replace with the desired replacement string
        }):'';
        RedditModel redditModel = RedditModel(
            url: objectToFetch['permalink'],
            title: objectToFetch['title'],
            isVideo: objectToFetch['is_video'],
            thumbnail: objectToFetch['preview']!=null?objectToFetch['preview']['images'][0]['resolutions'].length>2?objectToFetch['preview']['images'][0]['resolutions'][2]['url']:objectToFetch['preview']['images'][0]['resolutions'][1]['url']:'',
            fullText: objectToFetch['selftext'],
            createdAt: objectToFetch['created_utc'],
            authorName: objectToFetch['author'],
            subreddit: objectToFetch['subreddit'],
            upvoteRatio: objectToFetch['upvote_ratio'],
            upVotes: objectToFetch['ups'],
            videoUrl: objectToFetch['is_video']?'$sourceUrl$videoUrl&audio_url=$audioUrl':''
        );
        subredditPostList.add(redditModel);
      }
      loadingProgress = false;
      notifyListeners();
    }
  }

  Future<void> getPostDetails()async{
    detailsPageList.clear();
    var response = await http.get(Uri.parse(detailedPostUrl));
    var jsonObject = json.decode(response.body);
    var objectToFetch = jsonObject[1];
    for(var v in objectToFetch['data']['children']){
      if(v['data']['author']!=null){
        RedditModel redditModel = RedditModel(authorName: v['data']['author'], fullText: v['data']['body'], upVotes: v['data']['ups'], textVisible: true);
        detailsPageList.add(redditModel);
      }
    }
    notifyListeners();
  }

  Future<String?> fetchVideoUrl(postUrl, context, {size})async{
    var response = await http.get(Uri.parse(postUrl));
    var document = html_parser.parse(response.body);
    var videoUrl = document.getElementsByClassName('block h-full w-full max-h-full max-w-full').first.attributes['src'];
    return videoUrl;
  }

  void shareRedditPost(String url, context, bool isVideo, String postUrl)async{
    final directory = await getApplicationCacheDirectory();
    print(url);
    var response = await http.get(Uri.parse(url));
    String extension = isVideo?'.mp4':'.png';
    File file = File('${directory.path}/shared-file$extension');
    await file.writeAsBytes(response.bodyBytes);
    Share.shareFiles(['${directory.path}/shared-file$extension']);
    ///storage/emulated/0/Download/12.mp4
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

  showVidePlayerDialog(context, String videoUrl, Size size){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: SizedBox(
            height: size.height*0.6,
            width: size.width,
            child: VideoPlayerWidget(videoUrl: videoUrl,),
          ),
        );
      }
    );
  }

  void saveFile(bool isVideo, String imageUrl, String videoUrl, context)async{
    showProgressDialog(context);
    String extension = isVideo?'.mp4':'.jpg';
    File file = File('/storage/emulated/0/Download/CricVerse/${DateTime.now().millisecondsSinceEpoch}$extension');
    if(isVideo){
      fetchFile(file, videoUrl, isVideo, context);
    }else{
      fetchFile(file, imageUrl, isVideo, context);
    }
  }

  Future<void> fetchFile(File file, String url, bool isVideo, context)async{
    var response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    Fluttertoast.showToast(msg: '${isVideo?'Video':'Photo'} has been saved in your device.');
    Navigator.pop(context);
  }

}