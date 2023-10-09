import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  String url;
  MyVideoPlayer(this.url, {Key? key}) : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {

  late VideoPlayerController videoPlayerController;
  late FlickManager flickManager;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flickManager = FlickManager(
      autoPlay: false,
      videoPlayerController:
      VideoPlayerController.networkUrl(Uri.parse(widget.url)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FlickVideoPlayer(
            flickManager: flickManager
        ),
      ),
    );
  }
}
