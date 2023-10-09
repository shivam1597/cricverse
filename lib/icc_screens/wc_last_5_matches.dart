import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flags_info.dart';

class WCLast5Matches extends StatelessWidget {
  Size size;
  String team1;
  Map<String, dynamic> matchCentreMap;
  String team2;
  WCLast5Matches(this.size, this.team1, this.matchCentreMap, this.team2, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: size.width,
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Text('Last 5 Matches', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w700, fontSize: 20),),
          const SizedBox(height: 15,),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: size.width*0.48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        child: Image.network(flags[team1].toString()),
                      ),
                      const SizedBox(height: 20,),
                      Text(matchCentreMap['team1Name'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                      const SizedBox(height: 10,),
                      Text('World Cup: ${matchCentreMap['team1cwcCount']}', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                      const SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: matchCentreMap['team1Results'].length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: Text(matchCentreMap['team1Results'][index]['opponentName'],
                                style: GoogleFonts.poppins(color: matchCentreMap['team1Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300]),),
                              trailing: Text(matchCentreMap['team1Results'][index]['matchResult'],
                                  style: GoogleFonts.poppins(color: matchCentreMap['team1Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300])),
                              subtitle: Text(matchCentreMap['team1Results'][index]['matchResultLong'],
                                  style: GoogleFonts.poppins(color: matchCentreMap['team1Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300])),
                            );
                          },
                        ),
                      )
                    ],
                  ), //team1,
                ),
                SizedBox(
                  width: size.width*0.48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        child: Image.network(flags[team2].toString()),
                      ),
                      const SizedBox(height: 20,),
                      Text(matchCentreMap['team2Name'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                      const SizedBox(height: 10,),
                      Text('World Cup: ${matchCentreMap['team2cwcCount']}', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),),
                      const SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: matchCentreMap['team1Results'].length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: Text(matchCentreMap['team2Results'][index]['opponentName'],
                                style: GoogleFonts.poppins(color: matchCentreMap['team2Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300]),),
                              trailing: Text(matchCentreMap['team2Results'][index]['matchResult'],
                                style: GoogleFonts.poppins(color: matchCentreMap['team2Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300]),),
                              subtitle: Text(matchCentreMap['team2Results'][index]['matchResultLong'],
                                style: GoogleFonts.poppins(color: matchCentreMap['team2Results'][index]['matchResult']=='W'?Colors.green[300]: Colors.red[300]),),
                            );
                          },
                        ),
                      )
                    ],
                  ), //team2,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
