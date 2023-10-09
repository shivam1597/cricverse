import 'dart:io';
import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/meme_templates_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MemeTemplatesList extends StatefulWidget {
  const MemeTemplatesList({Key? key}) : super(key: key);

  @override
  State<MemeTemplatesList> createState() => _MemeTemplatesListState();
}

class _MemeTemplatesListState extends State<MemeTemplatesList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<MemeTemplateProvider>(context, listen: false);
      provider.fetchMemeTemplates();
      scrollController.addListener(() {
        if(scrollController.offset==scrollController.position.maxScrollExtent){
          provider.fetchMemeTemplates();
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<MemeTemplateProvider>(
      builder: (context, memeTemplateProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              children: [
                memeTemplateProvider.memeTemplates.isNotEmpty? GridView.count(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1/1.2,
                  children: List.generate(memeTemplateProvider.memeTemplates.length, (index){
                    final entry = memeTemplateProvider.memeTemplates.entries.elementAt(index);
                    final key = entry.key;
                    final value = entry.value;
                    return GestureDetector(
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network('https:$value', height: 130, fit: BoxFit.cover, width: double.infinity,),
                                ),
                                Flexible(
                                  child: Text(key, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500), overflow: TextOverflow.fade,),
                                )
                              ],
                            ),
                            Positioned(
                                bottom: 30,
                                right:2,
                                child: GestureDetector(
                                  onTap: ()async{
                                    if(index%3==0){
                                      memeTemplateProvider.loadAd();
                                      memeTemplateProvider.showInterstitialAd();
                                    }
                                    final directory = await getTemporaryDirectory();
                                    var response = await get(Uri.parse('https:$value'));
                                    File file = File('${directory.path}/ss-to-share.png');
                                    await file.writeAsBytes(response.bodyBytes);
                                    Share.shareFiles(['${directory.path}/ss-to-share.png'], text: 'Create a meme with $key template');
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    radius: 15,
                                    child: Icon(Icons.ios_share, color: Colors.white70, size: 18,),
                                  ),
                                )
                            )
                          ],
                        )
                    );
                  }),
                ): const Center(
                  child: CircularProgressIndicator(color: Color(0xffFE00A8),),
                ),
                const Positioned(
                  bottom: 5,
                  child: BannerAdWidget(),
                )
              ],
            )
          ),
        );
      },
    );
  }
}
