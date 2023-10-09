

// to get the source of video, format url like https://edge.api.brightcove.com/playback/v1/accounts/{account_id}/videos/{media_id}
import 'dart:async';
import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/my_video_player.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/bcci_video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/icc_videos_model.dart';

class BcciVideos extends StatefulWidget {
  const BcciVideos({Key? key}) : super(key: key);

  @override
  State<BcciVideos> createState() => _BcciVideosState();
}

class _BcciVideosState extends State<BcciVideos> {

  final ScrollController scrollController = ScrollController();
  static const MethodChannel methodChannel = MethodChannel('cricverse/customChannel');

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int minutes = duration.inMinutes;
    int remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String formatMillisecondsSinceEpoch(int millisecondsSinceEpoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String formattedDate = DateFormat('dd MMM, yy').format(dateTime);
    return formattedDate;
  }
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<BcciVideoProvider>(context, listen: false);
      final adsProvider = Provider.of<AdsProvider>(context, listen: false);
      provider.fetchVideos();
      provider.fetchDownloadedVideos();
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        adsProvider.loadAd();
        adsProvider.showInterstitialAd();
      });
      scrollController.addListener(() {
        if(scrollController.offset==scrollController.position.maxScrollExtent){
          provider.handlePageCount();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<BcciVideoProvider>(
      builder: (context, bcciProvider, child){
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
                        Text('Categories', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                        const SizedBox(height: 10,),
                        SizedBox(
                          height: 180,
                          child: GridView(
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1/0.6,
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3
                            ),
                            children: List.generate(bcciProvider.videosCategory.length, (index){
                              return GestureDetector(
                                onTap: ()=> bcciProvider.handleSelection(category: bcciProvider.videosCategory[index].toLowerCase()),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: bcciProvider.selectedCategory.toLowerCase()==bcciProvider.videosCategory[index].toLowerCase()?Colors.grey[400]:const Color(0xffFE00A8),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Text(bcciProvider.videosCategory[index].toString(), style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                                ),
                              );
                            }),
                          ),
                        ), // categories list
                        Text('Filter by formats:', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                        const SizedBox(height: 10,),
                        SizedBox(
                          height: 180,
                          child: GridView(
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1/0.6,
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3
                            ),
                            children: List.generate(bcciProvider.formats.length, (index){
                              return GestureDetector(
                                onTap: ()=> bcciProvider.handleSelection(format: bcciProvider.formats[index].toLowerCase()),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: bcciProvider.selectedFormat.toLowerCase()==bcciProvider.formats[index].toLowerCase()?Colors.grey[400]:const Color(0xffFE00A8),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Text(bcciProvider.formats[index].toString(), style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                                ),
                              );
                            }),
                          ),
                        ), // format grid list
                        const SizedBox(height: 10,),
                        SizedBox(height: size.height*0.3,),
                        bcciProvider.loadingMore?Column(
                          children: [
                            CircularProgressIndicator(
                              color: const Color(0xffFE00A8).withOpacity(0.7),
                            ),
                            const SizedBox(height: 10,),
                            Text('Loading more...', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 15),)
                          ],
                        ): const Center(),
                        bcciProvider.downloadingProgress?Container(
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
                        Text('Videos Source: BCCI', style: GoogleFonts.poppins(color: const Color(0xffFE00A8).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12),),

                      ],
                    ),
                  ),
                  Expanded(
                    child: bcciProvider.videosList.isNotEmpty? Column(
                      children: [
                        const BannerAdWidget(),
                        Expanded(
                          child: ListView.separated(
                            // controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: bcciProvider.videosList.length,
                            separatorBuilder: (context, index){
                              return const Divider(
                                height: 2,
                                color: Colors.white24,
                              );
                            },
                            itemBuilder: (context, index){
                              IccVideosModel videoModel = bcciProvider.videosList[index];
                              return ListTile(
                                onTap: ()async{
                                  bcciProvider.showProgressDialog(context);
                                  String videoUrl = await bcciProvider.getVideoUrl(videoModel.accountId!, videoModel.mediaId!);
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
                                          bcciProvider.showProgressDialog(context);
                                          String videoUrl = await bcciProvider.getVideoUrl(videoModel.accountId!, videoModel.mediaId!);
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
                                          if(!bcciProvider.savedVideos.contains(videoModel.titleUrlSegment)){
                                            String androidVersion = await methodChannel.invokeMethod('getVersion');
                                            bcciProvider.downloadVideoUrl = await bcciProvider.getVideoUrl(videoModel.accountId!, videoModel.mediaId!);
                                            bcciProvider.downloadVideoName = videoModel.titleUrlSegment!;
                                            if(int.parse(androidVersion.split('Android ').last)<13){
                                              var status = await Permission.storage.status;
                                              if(status.isGranted){
                                                bcciProvider.downloadVideo(context);
                                              }else if(status.isDenied){
                                                await Permission.storage.request();
                                              } else if(status.isPermanentlyDenied){
                                                await openAppSettings();
                                              }
                                            }
                                            {
                                              var status = await Permission.photos.status;
                                              if(status.isGranted){
                                                bcciProvider.downloadVideo(context);
                                              }
                                              else if(status.isDenied){
                                                await Permission.photos.request();
                                              }
                                              else if(status.isPermanentlyDenied){
                                                await openAppSettings();
                                              }
                                            }
                                          }else{
                                            Fluttertoast.showToast(msg: 'This video has already been downloaded.');
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.black26,
                                          child: Icon(bcciProvider.savedVideos.contains(videoModel.titleUrlSegment)?Icons.check:Icons.save_alt, color: Colors.white70, size: 20,),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  children: [
                                    Text(videoModel.title!, style: GoogleFonts.poppins(color: Colors.white70),),
                                    const SizedBox(height: 2,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${formatDuration(int.parse(videoModel.duration!))} min', style: GoogleFonts.poppins(color: Colors.white70),),
                                        Column(
                                          children: [
                                            Text('${videoModel.viewsCount!} views', style: GoogleFonts.poppins(color: Colors.white70),),
                                            Text(formatMillisecondsSinceEpoch(int.parse(videoModel.publishedDate!)*1000), style: GoogleFonts.poppins(color: Colors.white70),),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 2,),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    )
                        :  Center(child: CircularProgressIndicator(color: const Color(0xffFE00A8).withOpacity(0.7)),),
                  )
                ],
              ),
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
