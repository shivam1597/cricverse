import 'dart:convert';
import 'dart:io';

import 'package:cricverse/twitter_tags_screen/twitter_post_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
class TwitterProvider extends ChangeNotifier{

  FirebaseDatabase database = FirebaseDatabase.instance;
  Map<Object?, Object?>? dataValue;
  bool hasToShow = false;
  List<dynamic> postList = [];
  bool downloadInProgress = false;

  void getTwitterTagsInformation()async{
    DatabaseReference databaseReference = database.ref();
    var data = await databaseReference.child('trending_hashtags').once();
    dataValue = data.snapshot.value as Map<Object?, Object?>;
    hasToShow = dataValue!['has_to_show'] as bool;
    dataValue!.remove('has_to_show');
    notifyListeners();
  }

  Future<void> getTwitterPostJson(String sourceUrl, context, String hashtag)async{
    showProgressDialog(context);
    var response = await http.get(Uri.parse(sourceUrl));
    postList = json.decode(response.body);
    postList.removeWhere((element) => element['photoUrl']==null);
    notifyListeners();
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context)=> TwitterPostViewer(hashtag)));
  }

  void saveTwitterPost(String? imageUrl, String? videoUrl)async{
    const MethodChannel methodChannel = MethodChannel('cricverse/customChannel');
    String androidVersion = await methodChannel.invokeMethod('getVersion');
    if(int.parse(androidVersion.split('Android ').last)<13){
      var status = await Permission.storage.status;
      if(status.isGranted){
        _saveFileToDevice(imageUrl, videoUrl);
      }
      else if(status.isDenied){
        await Permission.storage.request();
      } else if(status.isPermanentlyDenied){
        await openAppSettings();
      }
    }
    else {
      var status = await Permission.photos.status;
      if(status.isGranted){
        _saveFileToDevice(imageUrl, videoUrl);
      }
      else if(status.isDenied){
        await Permission.photos.request();
      }
      else if(status.isPermanentlyDenied){
        await openAppSettings();
      }
    }
  }

  void _saveFileToDevice(String? imageUrl, String? videoUrl)async{
    downloadInProgress = true;
    notifyListeners();
    if(!await Directory('/storage/emulated/0/Download/CricVerse/TwitterPosts/').exists()){
      await Directory('/storage/emulated/0/Download/CricVerse/TwitterPosts/').create();
    }
    String downloadUrl = '';
    String extension = '';
    String toastMessage = '';
    if(videoUrl!=null){
      downloadUrl = videoUrl;
      extension = '.mp4';
      toastMessage = 'Video saved';
    }else{
      downloadUrl = imageUrl!;
      extension = '.png';
      toastMessage = 'Photo saved';
    }
    var response = await http.get(Uri.parse('https://video.twimg.com/amplify_video/1707055769684779008/vid/avc1/582x360/cyeJeZsHIeQIU7RM.mp4?tag=14'));
    File file = File('/storage/emulated/0/Download/CricVerse/CWCVideos/${DateTime.now().millisecondsSinceEpoch}$extension');
    await file.writeAsBytes(response.bodyBytes);
    downloadInProgress = false;
    Fluttertoast.showToast(msg: toastMessage);
    notifyListeners();
  }

  void showProgressDialog(context){
    showDialog(
      context: context,
      builder: (context){
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(
            child: CircularProgressIndicator(color: Color(0xffFE00A8),),
          ),
        );
      }
    );
  }

}