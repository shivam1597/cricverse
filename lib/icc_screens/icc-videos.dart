import 'dart:async';

import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/models/icc_videos_model.dart';
import 'package:cricverse/my_video_player.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'flags_info.dart';

class IccVideos extends StatefulWidget {
  const IccVideos({Key? key}) : super(key: key);

  @override
  State<IccVideos> createState() => _IccVideosState();
}

class _IccVideosState extends State<IccVideos> {

  final ScrollController scrollController = ScrollController();
  static const MethodChannel methodChannel = MethodChannel('cricverse/customChannel');
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<WorldCupFixtureProvider>(context, listen: false);
      scrollController.addListener(() {
        if(scrollController.offset==scrollController.position.maxScrollExtent){
          provider.handlePageCount();
        }
      });
      _timer = Timer.periodic(const Duration(seconds: 40), (timer) {
        provider.loadAd();
        provider.showInterstitialAd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<WorldCupFixtureProvider>(
      builder: (context, worldCupProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SizedBox(
                height: size.height,
                width: size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: size.width*0.32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Filter Videos', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 20),),
                          const SizedBox(height: 10,),
                          ...worldCupProvider.countryId.entries.map((e){
                            return GestureDetector(
                              onTap: ()=> worldCupProvider.handleCountryChange(e.key),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: worldCupProvider.selectedCountry==e.key? Colors.grey[400] :const Color(0xffFE00A8).withOpacity(0.6)
                                ),
                                child: Row(
                                  children: [
                                    Image.network(flags[e.key]!, height: 20, width: 20,),
                                    const SizedBox(width: 5,),
                                    Text(e.key, style: GoogleFonts.poppins(color: Colors.white70),)
                                  ],
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: size.height*0.18,),
                          // const BannerAdWidget(),
                          worldCupProvider.loadingMore?Column(
                            children: [
                              CircularProgressIndicator(
                                color: const Color(0xffFE00A8).withOpacity(0.7),
                              ),
                              const SizedBox(height: 10,),
                              Text('Loading more...', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 15),)
                            ],
                          ): const Center(),
                          worldCupProvider.downloadingProgress?Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: const Color(0xffFE00A8).withOpacity(0.7),
                                ),
                                const SizedBox(height: 10,),
                                Text('Download in progress...', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,)
                              ],
                            ),
                          ): const Center(),
                          Text('Videos Source: ICC', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12),),
                        ],
                      ),
                    ),
                    worldCupProvider.iccVideosList.isNotEmpty? Expanded(
                      child: Column(
                        children: [
                          const BannerAdWidget(),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: worldCupProvider.iccVideosList.length,
                              itemBuilder: (context, index){
                                IccVideosModel videoModel = worldCupProvider.iccVideosList[index];
                                return ListTile(
                                  onTap: ()async{
                                    worldCupProvider.showProgressDialog(context);
                                    String videoUrl = await worldCupProvider.getVideoUrl(videoModel.mediaId!);
                                    if(mounted){
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoPlayerWidget(videoUrl: videoUrl)));
                                    }
                                  },
                                  title: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(videoModel.thumbnailUrl!),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: ()async{
                                            worldCupProvider.showProgressDialog(context);
                                            String videoUrl = await worldCupProvider.getVideoUrl(videoModel.mediaId!);
                                            if(mounted){
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoPlayerWidget(videoUrl: videoUrl)));
                                            }
                                          },
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.black26,
                                            child: Icon(Icons.play_arrow_outlined, color: Colors.white70, size: 30,),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: GestureDetector(
                                          onTap:()async{
                                            if(!worldCupProvider.savedVideos.contains(videoModel.titleUrlSegment)){
                                              String androidVersion = await methodChannel.invokeMethod('getVersion');
                                              worldCupProvider.downloadVideoUrl = await worldCupProvider.getVideoUrl(videoModel.mediaId!);
                                              worldCupProvider.downloadVideoName = videoModel.titleUrlSegment!;
                                              if(int.parse(androidVersion.split('Android ').last)<13){
                                                var status = await Permission.storage.status;
                                                if(status.isGranted){
                                                  worldCupProvider.downloadVideo();
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
                                                  worldCupProvider.downloadVideo();
                                                }
                                                else if(status.isDenied){
                                                  await Permission.photos.request();
                                                }
                                                else if(status.isPermanentlyDenied){
                                                  await openAppSettings();
                                                }
                                              }
                                            }
                                          },
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.black26,
                                            child: Icon(worldCupProvider.savedVideos.contains(videoModel.titleUrlSegment)?Icons.check:Icons.save_alt, color: Colors.white70, size: 20,),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Text(videoModel.title!, style: GoogleFonts.poppins(color: Colors.white70),),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )
                        :  Center(child: CircularProgressIndicator(color: const Color(0xffFE00A8).withOpacity(0.7)),)
                  ],
                )
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer!.cancel();
  }
}
