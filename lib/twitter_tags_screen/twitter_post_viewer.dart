import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/twitter_provider.dart';
import 'package:cricverse/twitter_tags_screen/twitter_video_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TwitterPostViewer extends StatelessWidget {
  String hashtag;
  TwitterPostViewer(this.hashtag, {Key? key}) : super(key: key);

  final pattern = RegExp(r'#\w+');
  final emojiRemovalPattern = RegExp(r'[^\x00-\x7F]+');
  String convertCharacterToEmoji(String serverResponse) {
    // Convert the string to bytes and decode it as UTF-8
    List<int> bytes = serverResponse.codeUnits;
    String emoji = String.fromCharCodes(bytes);

    return emoji;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<TwitterProvider>(
      builder: (context, twitterProvider, child){
        return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text('#$hashtag', style: GoogleFonts.poppins(
                  color: Colors.white70, fontWeight: FontWeight.w800),),
              actions: [
                twitterProvider.downloadInProgress?const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),):const SizedBox(height: 1,)
              ],
            ),
            body: SizedBox(
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  const BannerAdWidget(),
                  const SizedBox(height: 20,),
                  Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: twitterProvider.postList.length,
                        separatorBuilder: (context, index){
                          return const Divider(color: Colors.white38,);
                        },
                        itemBuilder: (context, index){
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text(twitterProvider.postList[index]['captions'].replaceAll(pattern, '').replaceAll(emojiRemovalPattern, '')??'', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 16), textAlign: TextAlign.start,),),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                twitterProvider.postList[index]['videoUrl']!=null? MyVideoPlayer(twitterProvider.postList[index]['videoUrl'])
                                    : twitterProvider.postList[index]['photoUrl']!=null? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(twitterProvider.postList[index]['photoUrl']??'', fit: BoxFit.fitWidth,),
                                    )
                                ): const Center(),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.save_alt, color: Colors.white70,),
                                      onPressed: ()=> twitterProvider.saveTwitterPost(twitterProvider.postList[index]['photoUrl'], twitterProvider.postList[index]['videoUrl']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_browser, color: Colors.white70,),
                                      onPressed: ()async{
                                        if(await canLaunchUrl(Uri.parse('https://${twitterProvider.postList[index]['postUrl']}'))){
                                          await launchUrl(Uri.parse('https://${twitterProvider.postList[index]['postUrl']}'));
                                        }
                                      },
                                    ),
                                    GestureDetector(
                                      child: Text(''),
                                      onTap: ()async{
                                        if(await canLaunchUrl(Uri.parse('https://${twitterProvider.postList[index]['postUrl']}'))){
                                          await launchUrl(Uri.parse('https://${twitterProvider.postList[index]['postUrl']}'));
                                        }
                                      },
                                    )
                                  ],
                                )
                              ]
                          );
                        },
                      )
                  )
                ],
              ),
            )
        );
      },
    );
  }
}
