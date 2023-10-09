import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CommentaryScreen extends StatelessWidget {
  Size size;
  CommentaryScreen(this.size, {Key? key}) : super(key: key);

  String flagCountryName(String countryFlagName){
    if(countryFlagName.contains(' ')){
      List<String> splitName = countryFlagName.split(' ');
      if(splitName.last=='Women'){
        splitName.remove(splitName.last);
      }
      countryFlagName = splitName.join(' ');
    }
    return countryFlagName;
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ScorecardsProvider>(
      builder: (context, scorecardProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: ListView.separated(
            padding: const EdgeInsets.only(top: 5),
            physics: const BouncingScrollPhysics(),
            itemCount: scorecardProvider.commentaries.length,
            separatorBuilder: (context, index){
              Map<String, dynamic>? overEndingDetails = scorecardProvider.commentaries[index]['details'];
              return overEndingDetails!=null? ListTile(
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffFE00A8)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff310072)
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('End of over ${overEndingDetails!['over']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),),
                              Text('${overEndingDetails!['team']['abbreviation']}: ${overEndingDetails!['inningsRuns']}/${overEndingDetails!['inningsWickets']}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: SvgPicture.network(flagCountryName(flagUrlMap[overEndingDetails['team']['shortName']]!)),
                              ),
                              const SizedBox(width: 10,),
                              Text('${overEndingDetails['team']['fullName']} require ${overEndingDetails['requiredRuns']} off ${overEndingDetails['inningsMaxBalls']-overEndingDetails['inningsBalls']}', style: GoogleFonts.poppins(color: Colors.white),),
                            ],
                          ),
                          Text('${overEndingDetails['batsmanSummaries'][0]['batsman']['shortName']} ${overEndingDetails['batsmanSummaries'][0]['runs']} (${overEndingDetails['batsmanSummaries'][0]['balls']}), ${overEndingDetails['batsmanSummaries'][1]['batsman']['shortName']} ${overEndingDetails['batsmanSummaries'][1]['runs']} (${overEndingDetails['batsmanSummaries'][1]['balls']})',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 5,),
                          Text('${overEndingDetails['bowlerSummary']['bowler']['shortName']} ${overEndingDetails['bowlerSummary']['overs']}-${overEndingDetails['bowlerSummary']['maidens']}-${overEndingDetails['bowlerSummary']['runs']}-${overEndingDetails!['bowlerSummary']['wickets']}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 5,)
                        ],
                      ),
                    )
                  ],
                ),
              ): const Divider(color: Colors.grey,);
            },
            itemBuilder: (context, index){
              Map<String, dynamic>? ballDetails = scorecardProvider.commentaries[index]['ballDetails'];
              return ballDetails!=null? ListTile(
                leading: Text('${ballDetails['countingProgress']['over']}.${ballDetails!['countingProgress']['ball']}', style: GoogleFonts.poppins(color: Colors.white70),),
                title: Text(ballDetails!['message'], style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),),
                subtitle: Text('On strike: ${ballDetails!['facingBatsman']['shortName']}\nBowler: ${ballDetails!['bowler']['shortName']}', style: GoogleFonts.poppins(color: const Color(0xffFE00A8)),),
                trailing: CircleAvatar(
                  radius: 13,
                  backgroundColor: const Color(0xffFE00A8),
                  child: Text('${ballDetails!['activity']}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),),
                ),
              ): const Center();
            },
          ),
        );
      },
    );
  }
}
