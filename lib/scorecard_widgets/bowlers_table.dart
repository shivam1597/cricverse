import 'package:cricverse/providers/score_providers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BowlersTable extends StatelessWidget {
  List<dynamic>? currentSetInningBowlers;
  BowlersTable(this.currentSetInningBowlers, {Key? key}) : super(key: key);

  List<String> headerList = ['Player', 'Overs', 'Maid.', 'Runs', 'Wick.', 'Econ.'];

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        // Set the background color of the header row
        return const Color(0xff310072);
      }),
      columnSpacing: 28.0,
      dataRowHeight: 45.0, // Adjust the height of the rows as needed
      columns: headerList.map((String header) {
        return DataColumn(
          label: Text(
            header,
            style: GoogleFonts.poppins(
              color: Colors.white, // Header text color
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      rows: List<DataRow>.generate(currentSetInningBowlers!.length, // Number of additional rows
            (int index) {
          return DataRow(
            cells: headerList.map((String header) {
              String textToShow = '';
              if(header=='Player'){
                textToShow = currentSetInningBowlers![index]['player']['name'].toString()??'';
              } else if(header=='Overs'){
                textToShow = currentSetInningBowlers![index]['overs'].toString()??'';
              } else if(header=='Balls'){
                textToShow = currentSetInningBowlers![index]['balls'].toString()??'';
              } else if(header=="Maid."){
                textToShow = currentSetInningBowlers![index]['maidens'].toString()??'';
              } else if(header=="Wick."){
                textToShow = currentSetInningBowlers![index]['wickets'].toString()??'';
              } else if(header=='Runs'){
                textToShow = currentSetInningBowlers![index]['conceded'].toString()??'';
              } else if(header=='Econ.'){
                textToShow = currentSetInningBowlers![index]['economy'].toString()??'';
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
    );
  }
}
