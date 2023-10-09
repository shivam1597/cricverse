import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BatsmenScoreTable extends StatelessWidget {
  Size size;
  ScorecardsProvider scorecardProvider;
  int index;
  BatsmenScoreTable(this.size, this.scorecardProvider, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      border: const TableBorder(bottom: BorderSide(color: Colors.white30), horizontalInside: BorderSide(color: Colors.white30)),
      headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        // Set the background color of the header row
        return Colors.grey[900] as Color;
      }),
      columnSpacing: 10.0,
      dataRowHeight: 50.0, // Adjust the height of the rows as needed
      columns: scorecardProvider.battingHeaderList.map((String header) {
        return DataColumn(
          label: SizedBox(
            width: header=='Player'?size.width*0.37:30,
            child: Text(
              header,
              style: GoogleFonts.poppins(
                color: Colors.white70, // Header text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
      rows: List<DataRow>.generate(scorecardProvider.innings[index]['scorecard']['battingStats']!.length, // Number of additional rows
            (int index1) {
          var inningToShow = scorecardProvider.innings[index]['scorecard']['battingStats'][index1];
          return DataRow(
            cells: scorecardProvider.battingHeaderList.map((String header) {
              String textToShow = '';
              String dismissalText = inningToShow['mod']!=null?inningToShow['mod']['text']:'';
              // String playerRole = currentSetInningBatsmen![index]['playerRoleType']!='P'?'(${currentSetInningBatsmen![index]['playerRoleType'].toString()})':'';
              if(header=='Player'){
                // textToShow = '${currentSetInningBatsmen![index]['player']['name'].toString()}  $playerRole\n $dismissalText'??'';
                textToShow = '${scorecardProvider.playersMap[inningToShow['playerId'].toString()]}\n$dismissalText';
              } else if(header=='R'){
                textToShow = '${inningToShow['r']}';
              } else if(header=='B'){
                textToShow = '${inningToShow['b']}';
              } else if(header=="4's"){
                textToShow = '${inningToShow['4s']}';
              } else if(header=="6's"){
                textToShow = '${inningToShow['6s']}';
              } else if(header=='S/R'){
                textToShow = '${inningToShow['sr']}';
              }
              return DataCell(
                Text(
                  textToShow.toString()!='null'?textToShow:'',
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
    ); // batsmen table
  }
}
