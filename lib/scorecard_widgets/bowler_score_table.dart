import 'package:cricverse/providers/scorecards_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BowlerScoreTable extends StatelessWidget {
  Size size;
  ScorecardsProvider scorecardProvider;
  int index;
  BowlerScoreTable(this.size, this.scorecardProvider, this.index,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        // Set the background color of the header row
        return Colors.grey[900] as Color;
      }),
      columnSpacing: 10.0,
      dataRowHeight: 45.0, // Adjust the height of the rows as needed
      columns: scorecardProvider.bowlingHeaderList.map((String header) {
        return DataColumn(
          label: SizedBox(
            width: header=='Player'?size.width*0.32:32,
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
      rows: List<DataRow>.generate(scorecardProvider.innings[index]['scorecard']['bowlingStats']!.length, // Number of additional rows
            (int index1) {
          var inningToShow = scorecardProvider.innings[index]['scorecard']['bowlingStats'][index1];
          return DataRow(
            cells: scorecardProvider.bowlingHeaderList.map((String header) {
              String textToShow = '';
              String dismissalText = inningToShow['mod']!=null?inningToShow['mod']['text']:'';
              // String playerRole = currentSetInningBatsmen![index]['playerRoleType']!='P'?'(${currentSetInningBatsmen![index]['playerRoleType'].toString()})':'';
              if(header=='Player'){
                // textToShow = '${currentSetInningBatsmen![index]['player']['name'].toString()}  $playerRole\n $dismissalText'??'';
                textToShow = '${scorecardProvider.playersMap[inningToShow['playerId'].toString()]}';
              } else if(header=='O'){
                textToShow = '${inningToShow['ov']}';
              } else if(header=='M'){
                textToShow = '${inningToShow['maid']}';
              } else if(header=="R"){
                textToShow = '${inningToShow['r']}';
              } else if(header=="W"){
                textToShow = '${inningToShow['w']}';
              } else if(header=='Econ'){
                textToShow = '${inningToShow['e']}';
              } else if(header=='Dots'){
                textToShow = '${inningToShow['d']}';
              }
              return DataCell(
                Text(
                  textToShow,
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
    ); // bowler table
  }
}
