import 'package:cricverse/icc_screens/icc-videos.dart';
import 'package:cricverse/my_video_player.dart';
import 'package:cricverse/providers/cwc_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreenIccVideos extends StatefulWidget {
  const HomeScreenIccVideos({Key? key}) : super(key: key);

  @override
  State<HomeScreenIccVideos> createState() => _HomeScreenIccVideosState();
}

class _HomeScreenIccVideosState extends State<HomeScreenIccVideos> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<WorldCupFixtureProvider>(context, listen: false);
      provider.fetchIccVideos();
      provider.fetchDownloadedVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<WorldCupFixtureProvider>(
      builder: (context, worldCupProvider, child){
        return worldCupProvider.iccVideosList.isNotEmpty? ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index){
            return GestureDetector(
              onTap: ()async{
                worldCupProvider.showProgressDialog(context);
                String videoUrl = await worldCupProvider.getVideoUrl(worldCupProvider.iccVideosList[index].mediaId!);
                if(mounted){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const IccVideos()));
                }
                Future.delayed(const Duration(milliseconds: 200)).then((value){
                  if(mounted){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoPlayerWidget(videoUrl: videoUrl)));
                  }
                });
              },
              child: Container(
                height: 170,
                width: size.width*0.52,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white70)
                ),
                child:Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(worldCupProvider.iccVideosList[index].thumbnailUrl!, fit: BoxFit.fitWidth, height: 120,),
                        ),
                        const Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: Icon(Icons.play_arrow_outlined, color: Colors.white,),
                            )
                        )
                      ],
                    ),
                    Expanded(
                      child: Text(worldCupProvider.iccVideosList[index].title!, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700), overflow: TextOverflow.fade, textAlign: TextAlign.center,),
                    )
                  ],
                ),
              ),
            );
          },
        )
            : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),);
      },
    );
  }
}
