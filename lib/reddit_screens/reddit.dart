import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/my_video_player.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/reddit_provider.dart';
import 'package:cricverse/reddit_screens/post_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubRedditScreen extends StatefulWidget {
  SubRedditScreen({Key? key}) : super(key: key);

  @override
  State<SubRedditScreen> createState() => _SubRedditScreenState();
}

class _SubRedditScreenState extends State<SubRedditScreen> {

  final unescape = HtmlUnescape();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<RedditProvider>(context, listen: false);
      provider.fetchSubreddit();
      scrollController.addListener(() {
        if(scrollController.offset==scrollController.position.maxScrollExtent){
          provider.fetchSubreddit();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<RedditProvider>(
      builder: (context, redditProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            centerTitle: true,
            title: GestureDetector(
              onTap: () {
                redditProvider.subredditPostList.clear();
                redditProvider.handleUrlChange();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70,),
                  Text(redditProvider.subredditUrls[redditProvider.subredditIndex].split('/')[redditProvider.subredditUrls[redditProvider.subredditIndex].split('/').length-2],
                    style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 16),),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                ],
              )
            ),
            actions: [
              redditProvider.loadingProgress?const Center(
                child: CircularProgressIndicator(color: Color(0xffFE00A8),),
              ): const Center()
            ],
          ),
          // body: Image.network(unescape.convert('https://external-preview.redd.it/cjZ5Z2h5dG1pb2diMRruS1YnvQpNJYsf-yoPl-y4IlQ8crvk1bbtJpKaLH7O.png?width=108&amp;crop=smart&amp;format=pjpg&amp;auto=webp&amp;s=01b4e57ab07829f22e0d499274e2b21d2c37177a')),
          body: Stack(
            children: [
              redditProvider.subredditPostList.isNotEmpty? ListView.separated(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: redditProvider.subredditPostList.length,
                separatorBuilder: (context, index){
                  return Divider(color: Colors.grey[300], height: 4,);
                },
                itemBuilder: (context, index){
                  final listObject = redditProvider.subredditPostList[index];
                  final upVotes = listObject.upVotes;
                  final ratio = listObject.upvoteRatio;
                  return ListTile(
                    onTap: (){
                      if(index%3==0||index%7==0){
                        final provider = Provider.of<AdsProvider>(context, listen: false);
                        provider.loadAd();
                        provider.showInterstitialAd();
                      }
                      redditProvider.handlePostDetailUrl(redditProvider.subredditPostList[index].url.toString(), redditProvider.subredditPostList[index]);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const RedditPostDetails()));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // RandomAvatar(listObject.authorName.toString(), height: 30, width: 20),
                            const SizedBox(width: 5,),
                            Text('${listObject.authorName.toString()}\nr/${listObject.subreddit.toString()}', style: GoogleFonts.baloo2(color: Colors.white),),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Text(listObject.title.toString(),
                          style: GoogleFonts.b612(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),),
                        const SizedBox(height: 15,),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        listObject.thumbnail!.length>5? GestureDetector(
                          onTap: ()async{
                            if(redditProvider.subredditPostList[index].isVideo!){
                              redditProvider.showProgressDialog(context);
                              String? url = await redditProvider.fetchVideoUrl('https://www.reddit.com${redditProvider.subredditPostList[index].url.toString()}', context, size: size);
                              if(mounted){
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoPlayerWidget(videoUrl: url!)));
                              }
                            }
                          },
                          child: GestureDetector(
                            onTap: ()=> showImageDialog(unescape.convert(listObject.thumbnail.toString())),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Image.network(unescape.convert(listObject.thumbnail.toString()),
                                      fit: BoxFit.fitWidth,),
                                  ),
                                  listObject.isVideo!?const Center(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black26,
                                      child: Icon(Icons.play_arrow_outlined, color: Colors.white70, size: 45,),
                                    ),
                                  ): const Center()
                                ],
                              ),
                            ),
                          ),
                        ) : listObject.fullText!.length>5?
                        RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: listObject.fullText.toString().substring(0, listObject.fullText!.length<240?listObject.fullText!.length:240),
                                  style: GoogleFonts.b612(color: Colors.white,),
                                ),
                                TextSpan(
                                  text: '... Read More',
                                  style: GoogleFonts.b612(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                )
                              ]
                          ),
                        ) : const Center(),
                        SizedBox(
                          height: 50,
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_drop_up_sharp, size: 35, color: Color(0xffFE00A8),),
                                      Text(NumberFormat.compact().format(upVotes!.ceil()), style: GoogleFonts.b612(color: Colors.white),)
                                    ],
                                  ),
                                  const SizedBox(width: 5,),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_drop_down_sharp, size: 35, color: Color(0xffFE00A8),),
                                      Text(NumberFormat.compact().format(((upVotes!-ratio!*upVotes)/ratio).ceilToDouble()), style: GoogleFonts.b612(color: Colors.white,),)
                                    ],
                                  ),
                                  const SizedBox(width: 15,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          icon: const Icon(
                                            Icons.save_alt, color: Color(0xffFE00A8), size: 26,
                                          ),
                                          onPressed: ()=> redditProvider.saveFile(
                                              redditProvider.subredditPostList[index].isVideo as bool, unescape.convert(redditProvider.subredditPostList[index].thumbnail.toString()),
                                              redditProvider.subredditPostList[index].videoUrl.toString(), context
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Transform.rotate(
                                  angle: -25 * 3.14 / 180, // 45 degrees in radians (clockwise)
                                  child: const Icon(
                                    Icons.send_rounded, color: Color(0xffFE00A8), size: 26,
                                  ),
                                ),
                                onPressed: (){
                                  if(redditProvider.subredditPostList[index].thumbnail!.length>10){
                                    String fileUrl = redditProvider.subredditPostList[index].isVideo!?redditProvider.subredditPostList[index].videoUrl!:redditProvider.subredditPostList[index].thumbnail!;
                                    redditProvider.shareRedditPost(unescape.convert(fileUrl), context,
                                        redditProvider.subredditPostList[index].isVideo!, 'https://www.reddit.com${redditProvider.subredditPostList[index].url}');
                                  }
                                  // chatProvider.showContactsBottomSheet(context, size, context.isDarkMode); // to show bottom sheet without lag
                                  // chatProvider.constructMessage(redditProvider.subredditPostList[index].url.toString());
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              )
                  : const Center(child: CircularProgressIndicator(color: Color(0xffFBA637),),),
              const Positioned(
                bottom: 5,
                child: BannerAdWidget(),
              )
            ],
          )
        );
      },
    );
  }

  void showVideoPlayer(String videoPlayer){
    showDialog(
      context: context,
      builder: (context){
        return VideoPlayerWidget(videoUrl: 'videoUrl');
      }
    );
  }

  void showImageDialog(String url){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: SizedBox(
              height: 300,
              child: Center(child: Image.network(url, fit: BoxFit.cover,),),
            ),
          );
        }
    );
  }
}
