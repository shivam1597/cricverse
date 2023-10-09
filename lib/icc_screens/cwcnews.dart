import 'package:cricverse/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../news_screens/news_browser.dart';

class CwcNewsScreen extends StatefulWidget {
  const CwcNewsScreen({Key? key}) : super(key: key);

  @override
  State<CwcNewsScreen> createState() => _CwcNewsScreenState();
}

class _CwcNewsScreenState extends State<CwcNewsScreen> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<NewsProvider>(context, listen: false);
      provider.fetchCWCNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child){
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: newsProvider.cwcNewsList.length,
          itemBuilder: (context, index){
            final newsModel = newsProvider.cwcNewsList[index];
            final GlobalKey itemKey = GlobalKey();
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> NewsBrowser(newsModel.url!)));
              },
              child: Container(
                width: size.width,
                margin: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: itemKey,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(newsModel.thumbnail!, fit: BoxFit.cover, width: size.width,),
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              Text(
                                newsModel.subtitle!,
                                style: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Text(
                            newsModel.title!,
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(newsModel.publishedTime!.substring(0, 10),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 5,),
                            IconButton(
                              icon: Transform.rotate(
                                angle: -25 * 3.14 / 180, // 45 degrees in radians (clockwise)
                                child: const Icon(
                                  Icons.send_rounded, color: Color(0xffFE00A8), size: 22,
                                ),
                              ),
                              onPressed: (){
                                newsProvider.takeScreenShotAndShare(itemKey, newsModel.url!, newsModel.title!);
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
