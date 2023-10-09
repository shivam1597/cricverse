import 'dart:async';
import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/reddit_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RedditPostDetails extends StatefulWidget {
  const RedditPostDetails({Key? key}) : super(key: key);

  @override
  State<RedditPostDetails> createState() => _RedditPostDetailsState();
}

class _RedditPostDetailsState extends State<RedditPostDetails> {

  var unescape = HtmlUnescape();
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<RedditProvider>(context, listen: false);
      final adsProvider = Provider.of<AdsProvider>(context, listen: false);
      provider.getPostDetails();
      _timer = Timer.periodic(const Duration(seconds: 40), (timer) {
        adsProvider.loadAd();
        adsProvider.showInterstitialAd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<RedditProvider>(
      builder: (context, redditProvider, child){
        final upVotes = redditProvider.detailsPageModel.upVotes;
        final ratio = redditProvider.detailsPageModel.upvoteRatio;
        return SafeArea(
          child: Scaffold(
              backgroundColor: Colors.black,
              body: RawScrollbar(
                thickness: 4,
                child: redditProvider.detailsPageList.isNotEmpty? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const BannerAdWidget(),
                        ListTile(
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // RandomAvatar(redditProvider.detailsPageModel.authorName.toString(), height: 30, width: 20),
                                  const SizedBox(width: 5,),
                                  Text('${redditProvider.detailsPageModel.authorName.toString()}\nr/${redditProvider.detailsPageModel.subreddit.toString()}', style: GoogleFonts.baloo2(color: Colors.white),),
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Text(redditProvider.detailsPageModel.title.toString(),
                                style: GoogleFonts.b612(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),),
                              const SizedBox(height: 15,),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              redditProvider.detailsPageModel.thumbnail!.length>5?ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(unescape.convert(redditProvider.detailsPageModel.thumbnail.toString()),
                                  fit: BoxFit.fitWidth,),
                              ) : redditProvider.detailsPageModel.fullText!.length>5? Text(redditProvider.detailsPageModel.fullText.toString(), style: GoogleFonts.b612(color: Colors.white,),)
                                  : const Center(),
                              Container(
                                height: 50,
                                width: size.width,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.arrow_drop_up_sharp, size: 35, color: Color(0xffFBA637),),
                                        Text(NumberFormat.compact().format(redditProvider.detailsPageModel.upVotes!.ceil()), style: GoogleFonts.b612(color: Colors.white),)
                                      ],
                                    ),
                                    const SizedBox(width: 5,),
                                    Column(
                                      children: [
                                        const Icon(Icons.arrow_drop_down_sharp, size: 35, color: Color(0xffFBA637),),
                                        Text(NumberFormat.compact().format(((upVotes!-ratio!*upVotes)/ratio).ceilToDouble()), style: GoogleFonts.b612(color: Colors.white,),)
                                      ],
                                    ),
                                    const SizedBox(width: 15,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10,),
                                        Container(
                                          height: 30,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Text(redditProvider.detailsPageModel.subreddit.toString(), style: GoogleFonts.b612(color: Colors.white),),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[300],)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Column(
                          children: List.generate(redditProvider.detailsPageList.length, (index){
                            final listObject = redditProvider.detailsPageList[index];
                            final upVotes = listObject.upVotes;
                            return ListTile(
                              // onTap: ()=> redditProvider.handleDetailPageListTap(index),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // RandomAvatar(listObject.authorName.toString(), height: 30, width: 20),
                                      const SizedBox(width: 5,),
                                      Text(listObject.authorName.toString(), style: GoogleFonts.baloo2(color: Colors.white),),
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                ],
                              ),
                              subtitle: listObject.textVisible!? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  listObject.thumbnail!=null&&listObject.thumbnail!.length>5?ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(unescape.convert(listObject.thumbnail.toString()),
                                      fit: BoxFit.fitWidth,),
                                  ) : listObject.fullText !=null&& listObject.fullText!.length>5?
                                  SelectableText(listObject.fullText.toString(), style: GoogleFonts.b612(color: Colors.white),
                                    // onTap: ()=> redditProvider.handleDetailPageListTap(index),
                                  ) : const Center(),
                                  SizedBox(
                                    height: 50,
                                    width: size.width,
                                    // margin: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.arrow_drop_up_sharp, size: 35, color: Color(0xffFBA637),),
                                            upVotes!=null?Text(NumberFormat.compact().format(upVotes), style: GoogleFonts.b612(color: Colors.white),): const Center()
                                          ],
                                        ),
                                        const SizedBox(width: 15,),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.grey[300],)
                                ],
                              ): const Center(),
                            );
                          }),
                        ),
                      ],
                    )
                )
                    : const Center(child: CircularProgressIndicator(color: Color(0xffFBA637),),
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
