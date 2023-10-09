import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/news_screens/news_browser.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

  final ScrollController scrollController = ScrollController();
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat.yMMMd().format(dateTime); // If more than a day, show the date
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    } else {
      return difference.inSeconds.isNegative?'':"${difference.inSeconds} ${difference.inSeconds == 1 ? 'second' : 'seconds'} ago";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<NewsProvider>(context, listen: false);
      scrollController.addListener(() {
        if(scrollController.offset==scrollController.position.maxScrollExtent){
          provider.handlePageChange();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child){
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: Text('Cricket News', style: GoogleFonts.poppins(color: Colors.purple[300], fontWeight: FontWeight.w700),),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: newsProvider.pageLoading? const CircularProgressIndicator(color: Color(0xffFE00A8),)
                      : GestureDetector(
                    onTap: ()=> scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.decelerate),
                    child: const Icon(Icons.arrow_circle_up, color: Colors.white70,),
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: newsProvider.newsList.length,
                itemBuilder: (context, index){
                  return ListTile(
                      onTap: (){
                        if(index%3==0||index%7==0){
                          final provider = Provider.of<AdsProvider>(context, listen: false);
                          provider.loadAd();
                          provider.showInterstitialAd();
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser(newsProvider.newsList[index]['url']!)));
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        //NetworkImage(newsItem['images'][0]['url'])
                        child: newsProvider.newsList[index]['imageUrl']!.length>5? Image.network('https://www.bing.com/${newsProvider.newsList[index]['imageUrl']}', height: size.height,)
                            : Image.asset('assets/images/cric_verse_icon.png'),
                      ),
                      title: Text(newsProvider.newsList[index]['title']!, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),),
                      subtitle: Column(
                        children: [
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(newsProvider.newsList[index]['author']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),),
                                  const SizedBox(width: 5,),
                                  const Text('•', style: TextStyle(color: Colors.white70),),
                                  const SizedBox(width: 5,),
                                  Text('${newsProvider.newsList[index]['timeAgo']!} Ago', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),)
                                ],
                              ),
                              GestureDetector(
                                onTap: ()=>Share.share(newsProvider.newsList[index]['url']!),
                                child: const Icon(Icons.ios_share, color: Colors.white70,),
                              )
                            ],
                          ),
                        ],
                      )
                  );
                },
              ),
              const Positioned(
                bottom: 5,
                child: BannerAdWidget(),
              )
            ],
          ),
        );
      },
    );
  }
}
