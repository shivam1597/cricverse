import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late FlickManager flickManager;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      autoPlay: true,
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
    );
    Future.delayed(const Duration(milliseconds: 200)).then((value){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: FlickVideoPlayer(
        flickManager: flickManager,
        preferredDeviceOrientationFullscreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      ),
    );
  }
}
