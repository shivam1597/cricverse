import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/ads_provider.dart';
import 'package:cricverse/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../news_screens/news_browser.dart';

class NewsHomeList extends StatefulWidget {
  const NewsHomeList({Key? key}) : super(key: key);

  @override
  State<NewsHomeList> createState() => _NewsHomeListState();
}

class _NewsHomeListState extends State<NewsHomeList> {

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
      provider.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child){
        return newsProvider.newsList.isNotEmpty? Column(
          children: [
            ...List.generate(5, (index){
              return ListTile(
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser(newsProvider.newsList[index]['url']!))),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    //NetworkImage(newsItem['images'][0]['url'])
                    child: newsProvider.newsList[index]['imageUrl']!.length>5? Image.network('https://www.bing.com/${newsProvider.newsList[index]['imageUrl']}', height: size.height,)
                        : Image.asset('assets/images/cric_verse_icon.png',),
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
            }),
            const BannerAdWidget()
          ],
        ) 
            : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),);
      },
    );
  }
}
