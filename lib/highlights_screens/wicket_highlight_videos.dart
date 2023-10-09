import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/my_video_player.dart';
import 'package:cricverse/providers/cwc_highlights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


class WicketHighlightVideos extends StatelessWidget {
  const WicketHighlightVideos({Key? key}) : super(key: key);

  static const MethodChannel methodChannel = MethodChannel('cricverse/customChannel');
  @override
  Widget build(BuildContext context) {
    return Consumer<CricketHighlightProvider>(
      builder: (context, wicketProvider, child){
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: Text('${wicketProvider.videosMetaData.first['title']!.split('-').last} Wickets', style: GoogleFonts.poppins(color: Colors.white70),),
          ),
          backgroundColor: Colors.black,
          body: Column(
            children: [
              const BannerAdWidget(),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: wicketProvider.videosMetaData.length,
                  separatorBuilder: (context, index){
                    return wicketProvider.videosMetaData[index]['thumbnail']!=null? const Divider(height: 2, color: Colors.grey,): const Center();
                  },
                  itemBuilder: (context, index){
                    return wicketProvider.videosMetaData[index]['thumbnail']!=null? Padding(
                      padding: const EdgeInsets.all(15),
                      child: ListTile(
                        onTap: ()async{
                          wicketProvider.showProgressDialog(context);
                          await wicketProvider.getVideoUrl(wicketProvider.videosMetaData[index]['videoId']!).then((videoUrl){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoPlayerWidget(videoUrl: videoUrl,)));
                          });
                        },
                        title: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(wicketProvider.videosMetaData[index]['thumbnail']!,),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: Icon(Icons.play_arrow_outlined, color: Colors.white60, size: 35,),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            const SizedBox(height: 10,),
                            Text(wicketProvider.videosMetaData[index]['title']!, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500),),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(height: 1,),
                                GestureDetector(
                                  onTap: ()async{
                                    String androidVersion = await methodChannel.invokeMethod('getVersion');
                                    wicketProvider.downloadUrl = await wicketProvider.getVideoUrl(wicketProvider.videosMetaData[index]['videoId']!);
                                    wicketProvider.downloadVideoName = wicketProvider.videosMetaData[index]['title']!;
                                    if(int.parse(androidVersion.split('Android ').last)<13){
                                      var status = await Permission.storage.status;
                                      if(status.isGranted){
                                        wicketProvider.downloadVideo(index);
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
                                        wicketProvider.downloadVideo(index);
                                      }
                                      else if(status.isDenied){
                                        await Permission.photos.request();
                                      }
                                      else if(status.isPermanentlyDenied){
                                        await openAppSettings();
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width*0.35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color(0xffFE00A8)
                                    ),
                                    child: Text('Download Video', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: wicketProvider.downloadingProgress && wicketProvider.downloadingVideoIndex==index? const CircularProgressIndicator(color: Color(0xffFE00A8),)
                                      : const Center(),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ): const Center();
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
