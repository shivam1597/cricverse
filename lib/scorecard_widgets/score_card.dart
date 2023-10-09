import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/api_service.dart';
import 'package:cricverse/scorecard_widgets/bowlers_table.dart';
import 'package:cricverse/sub_home_screens/live_animation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreCard extends StatefulWidget {
  String url;
  ScoreCard(this.url,{Key? key}) : super(key: key);

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard>{

  Map<String, dynamic> firstInningMap = {};
  Map<String, dynamic> secondInningMap = {};
  Map<String, dynamic> currentInning = {};
  List<dynamic>? firstInningBatsmen = [];
  List<dynamic>? firstInningBowlers = [];
  List<dynamic>? firstInningsWicket = [];
  List<dynamic>? firstInningFallOfWickets = [];
  List<dynamic>? secondInningBatsmen = [];
  List<dynamic>? secondInningBowlers = [];
  List<dynamic>? secondInningsWicket = [];
  List<dynamic>? secondInningFallOfWickets = [];
  Map<String, dynamic>? firstInningsTeam = {};
  Map<String, dynamic>? secondInningsTeam = {};
  List<Map<String, dynamic>>? ballComments = [];
  Map<String, dynamic> matchInfo = {};
  String currentSetInning = 'Inning 1';
  List<dynamic>? currentSetInningBatsmen = [];
  List<dynamic>? currentSetInningBowlers = [];
  String currentInningRuns = '';
  String currentInningWickets = '';
  String currentInningOver = '';
  String currentInningExtras = '';
  String currentSeriesId = '';
  String currentMatchId = '';
  ApiService? apiService;
  final List<String> headerList = ['Player', 'Runs', 'Balls', "4's", "6's", 'S/R'];

  String calculateOver(int? balls){
    String overAndBalls = '';
    if(balls!=null){
      int overs = balls ~/ 6; // Calculate the number of overs
      int remainingBalls = balls % 6; // Calculate the remaining balls
      overAndBalls = '$overs.$remainingBalls';
    }
    return overAndBalls;
  }
  
  void fetchScoreCard()async{
    apiService = ApiService(widget.url, 10);
    // var response = await http.get(Uri.parse('https://hs-consumer-api.espncricinfo.com/v1/pages/match/home?lang=en&seriesId=1392778&matchId=1392783'));
    apiService!.stream.listen((jsonObject) {
      var contentObject = jsonObject['content'] as Map<String, dynamic>;
      matchInfo = jsonObject['match'];
      if (contentObject['innings'] != null&&contentObject['innings'].length>0){
        firstInningMap = contentObject['innings'][0];
        ballComments = contentObject['innings'][0]['recentBallCommentary'];
        firstInningFallOfWickets = contentObject['innings'] != null ? contentObject['innings'][0]['inningFallOfWickets'] : [];
        firstInningsTeam = contentObject['innings'][0]['team'];
        firstInningsWicket = contentObject['innings'][0]['inningWickets'];
        firstInningBatsmen = contentObject['innings'][0]['inningBatsmen'];
        firstInningBowlers = contentObject['innings'][0]['inningBowlers'];
        if(contentObject['innings'].length>1){
          if(contentObject['innings'][1] != null){
            secondInningMap = contentObject['innings'][1];
            secondInningFallOfWickets = contentObject['innings'][1]['inningFallOfWickets'] ?? [];
            secondInningsTeam = contentObject['innings'][1]['team'];
            secondInningsWicket = contentObject['innings'][1]['inningWickets'];
            secondInningBatsmen = contentObject['innings'][1]['inningBatsmen'];
            secondInningBowlers = contentObject['innings'][1]['inningBowlers'];
          }
        }
      }
      else{
        Fluttertoast.showToast(msg: 'Match was not played.');
      }
      currentSetInningBatsmen = firstInningBatsmen;
      currentSetInningBowlers = firstInningBowlers;
      currentInning = firstInningMap;
      setState(() {});
    });
  }

  void handleInningChange(){
    if(secondInningMap.isNotEmpty){
      if(currentSetInning=='Inning 1'){
        currentSetInning = 'Inning 2';
        currentSetInningBatsmen = secondInningBatsmen;
        currentSetInningBowlers = secondInningBowlers;
        currentInning = secondInningMap;
        // int ball =
      }else{
        currentSetInning = 'Inning 1';
        currentSetInningBatsmen = firstInningBatsmen;
        currentSetInningBowlers = firstInningBowlers;
        currentInning = firstInningMap;
      }
      setState(() {});
    }else{
      Fluttertoast.showToast(msg: 'Second Innings results are not available.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchScoreCard();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pop(context);
        throw 'e';
      },
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: matchInfo['series']!=null? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(matchInfo['title']??'', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                Text(matchInfo['series']['alternateName']??'', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                Column(
                  children: [
                    Text('${currentInning['runs']}/${currentInning['wickets']}'??'',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                    Text(calculateOver(currentInning['balls'])??'', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                  ],
                )
              ],
            ): const SizedBox(height: 1,),
            actions: [
              matchInfo['state']=='LIVE'?const Padding(
                padding: EdgeInsets.all(10),
                child: LiveIndicator(),
              ): const SizedBox(height: 1,)
            ],
          ),
          body: currentSetInningBatsmen!.isNotEmpty? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(matchInfo['statusText'].toString()??'', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                const SizedBox(height: 10,),
                const BannerAdWidget(),
                Text(matchInfo['status'].toString()??'', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),),
                const SizedBox(height: 10,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      // Set the background color of the header row
                      return const Color(0xff310072);
                    }),
                    columnSpacing: 12.0,
                    dataRowHeight: 45.0, // Adjust the height of the rows as needed
                    columns: headerList.map((String header) {
                      return DataColumn(
                        label: SizedBox(
                          width: header=='Player'?160:30,
                          child: Text(
                            header,
                            style: GoogleFonts.poppins(
                              color: Colors.white, // Header text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    rows: List<DataRow>.generate(currentSetInningBatsmen!.length, // Number of additional rows
                          (int index) {
                        return DataRow(
                          cells: headerList.map((String header) {
                            String textToShow = '';
                            String dismissalText = currentSetInningBatsmen![index]['dismissalText']!=null?currentSetInningBatsmen![index]['dismissalText']['long']:'';
                            String playerRole = currentSetInningBatsmen![index]['playerRoleType']!='P'?'(${currentSetInningBatsmen![index]['playerRoleType'].toString()})':'';
                            if(header=='Player'){
                              textToShow = '${currentSetInningBatsmen![index]['player']['name'].toString()}  $playerRole\n $dismissalText'??'';
                            } else if(header=='Runs'){
                              textToShow = currentSetInningBatsmen![index]['runs'].toString()??'';
                            } else if(header=='Balls'){
                              textToShow = currentSetInningBatsmen![index]['balls'].toString()??'';
                            } else if(header=="4's"){
                              textToShow = currentSetInningBatsmen![index]['fours'].toString()??'';
                            } else if(header=="6's"){
                              textToShow = currentSetInningBatsmen![index]['sixes'].toString()??'';
                            } else if(header=='S/R'){
                              textToShow = currentSetInningBatsmen![index]['strikerate'].toString()??'';
                            }
                            return DataCell(
                              Text(
                                textToShow!='null'?textToShow:'',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  // Data cell text style
                                  fontSize: 12.0,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('     Fall Of Wickets: ', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                  ],
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: size.width,
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                        children: List.generate(currentInning['inningFallOfWickets'].length, (index){
                          final fowObject = currentInning['inningFallOfWickets'][index];
                          return TextSpan(
                            text: '   ${fowObject['fowRuns']}/${fowObject['fowWicketNum']} (${fowObject['fowOvers']})${index+1==currentInning['inningFallOfWickets'].length?'':','}',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          );
                        })
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: ()=> handleInningChange(),
                  child: SizedBox(
                    height: 50,
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70,),
                        const SizedBox(width: 20,),
                        Text(currentSetInning, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                        const SizedBox(width: 20,),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70,),
                      ],
                    ),
                  ),
                ),
                BowlersTable(currentSetInningBowlers)
              ],
            ),
          ): const Center(
            child: CircularProgressIndicator(
              color: Color(0xffFE00A8),
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    apiService!.dispose();
  }
}
