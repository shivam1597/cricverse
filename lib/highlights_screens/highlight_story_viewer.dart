import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';

class HighlightStoryViewer extends StatefulWidget {
  String urlListString;
  String videoLogo;
  String title;
  HighlightStoryViewer(this.urlListString, this.videoLogo, this.title, {Key? key}) : super(key: key);

  @override
  State<HighlightStoryViewer> createState() => _HighlightStoryViewerState();
}

class _HighlightStoryViewerState extends State<HighlightStoryViewer> {
  List<StoryItem> stories = [];
  List<dynamic> urlList = [];
  int _currentIndex = 0;
  bool downloadingProgress = false;
  String downloadingMessage = '';
  final controller = StoryController();
  static const MethodChannel methodChannel = MethodChannel('cricverse/customChannel');

  addStories(){
    urlList = json.decode(widget.urlListString);
    for(var v in urlList){
      stories.add(StoryItem.pageVideo(v, controller: controller));
    }
    setState(() {});
  }

  saveToDevice()async{
    if(!await Directory('/storage/emulated/0/Download/CricVerse/Highlights/').exists()){
      await Directory('/storage/emulated/0/Download/CricVerse/Highlights/').create();
    }
    File file = File('/storage/emulated/0/Download/CricVerse/Highlights/${DateTime.now().millisecondsSinceEpoch}.mp4');
    setState(() {
      downloadingProgress = true;
      downloadingMessage = 'Downloading video.\nPlease wait.';
    });
    var response = await http.get(Uri.parse(urlList[_currentIndex]));
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      downloadingProgress = false;
    });
    Fluttertoast.showToast(msg: 'Video saved');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: ()async{
              setState(() {
                downloadingProgress = true;
                downloadingMessage = 'Downloading video to share.\nPlease wait.';
              });
              final directory = await getTemporaryDirectory();
              File file = File('${directory.path}/story_to_share.mp4');
              var response = await http.get(Uri.parse(urlList[_currentIndex]));
              await file.writeAsBytes(response.bodyBytes);
              setState(() {
                downloadingProgress = false;
              });
              await Share.shareFiles(['${directory.path}/story_to_share.mp4']);
            },
            child: CircleAvatar(
              backgroundColor: const Color(0xffFE00A8),
              radius: 25,
              child: Transform.rotate(
                angle: -45 * 3.14159265359 / 180,
                child: const Icon(Icons.send, color: Colors.white,),
              ),
            ),
          ), // share button
          const SizedBox(height: 25),
          GestureDetector(
            onTap: ()async{
              if(!downloadingProgress){
                String androidVersion = await methodChannel.invokeMethod('getVersion');
                if(int.parse(androidVersion.split('Android ').last)<13){
                  var status = await Permission.storage.status;
                  if(status.isGranted){
                    saveToDevice();
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
                    saveToDevice();
                  }
                  else if(status.isDenied){
                    await Permission.photos.request();
                  }
                  else if(status.isPermanentlyDenied){
                    await openAppSettings();
                  }
                }
              }else{
                Fluttertoast.showToast(msg: 'Please wait while the video is being downloaded...');
              }
            },
            child: const CircleAvatar(
              backgroundColor: Color(0xffFE00A8),
              radius: 25,
              child: Icon(Icons.save_alt_rounded, color: Colors.white,),
            ),
          )
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(widget.title, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
      ),
      body: Stack(
        children: [
          StoryView(
              controller: controller,
              storyItems: stories,
              repeat: true, // should the stories be slid forever
              onStoryShow: (s) {
                Future.delayed(const Duration(milliseconds: 1)).then((value){
                  setState(() {
                    _currentIndex = stories.indexOf(s);
                  });
                });
              },
              onComplete: () => Navigator.pop(context),
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              }
          ),
          Positioned(
            bottom: 15,
            left: 5,
            child: Image.network(widget.videoLogo, height: 40,),
          ),
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width/3,
            child: downloadingProgress? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xffFE00A8),
                ),
                const SizedBox(height: 20,),
                Text('Downloading video to share.\nPlease wait.', style: GoogleFonts.poppins(color: Colors.white70), textAlign: TextAlign.center,)
              ],
            ): const Center()
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
}
