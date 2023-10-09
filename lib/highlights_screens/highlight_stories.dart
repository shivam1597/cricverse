import 'dart:convert';

import 'package:cricverse/highlights_screens/highlight_story_viewer.dart';
import 'package:cricverse/providers/cwc_highlights_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HighlightStoriesHome extends StatefulWidget {
  const HighlightStoriesHome({Key? key}) : super(key: key);

  @override
  State<HighlightStoriesHome> createState() => _HighlightStoriesHomeState();
}

class _HighlightStoriesHomeState extends State<HighlightStoriesHome> {

  Map<String, String> a = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<CricketHighlightProvider>(context, listen: false);
      provider.fetchStoriesList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CricketHighlightProvider>(
      builder: (context, highlightStoriesProvider, child){
        return SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 10,),
              Text('Watch Match Stories', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
              SizedBox(
                height: 170,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...highlightStoriesProvider.ampStories.entries.map((e){
                      Map<Object?, Object?> valuesMap = e.value as Map<Object?, Object?>;
                      return GestureDetector(
                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> HighlightStoryViewer(valuesMap['url_list'].toString(), valuesMap['video_logo'].toString(), valuesMap['title'].toString()))),
                        child: Container(
                            height: 160,
                            width: 160,
                            margin: const EdgeInsets.all(5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(base64Decode(valuesMap['thumbnail'].toString())),
                                ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black26,
                                    child: Icon(Icons.play_circle, color: Colors.white70,),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  child: Container(
                                    height: 20,
                                    width: 160,
                                    color: Colors.black87,
                                    child: Text(valuesMap['title'].toString(), style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const Positioned(
                                  right: 8,
                                  top: 25,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black26,
                                    child: Icon(Icons.amp_stories_outlined, color: Colors.white70,),
                                  ),
                                ),
                              ],
                            )
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
