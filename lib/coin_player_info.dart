import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;

class CoinPlayerInfo extends StatefulWidget {
  String playerUrl;
  CoinPlayerInfo(this.playerUrl, {Key? key}) : super(key: key);

  @override
  State<CoinPlayerInfo> createState() => _CoinPlayerInfoState();
}

class _CoinPlayerInfoState extends State<CoinPlayerInfo> {

  final List<List<String>> battingTable = [];
  final List<List<String>> bowlingTable = [];
  String playerName = '';
  String playerDpUrl = '';
  List<List<String>> tableToShow = [];
  List<String> tableName = ['Batting Stats', 'Bowling Stats'];
  String playerUrl = '';
  int tableNameIndex = 0;

  void handleTableChange(){
    if(tableNameIndex==0){
      tableNameIndex = 1;
      tableToShow = bowlingTable;
    }else{
      tableNameIndex = 0;
      tableToShow = battingTable;
    }
    setState(() {});
  }
  
  void parsePlayerStats()async{
    final response = await http.get(Uri.parse('https://www.cricbuzz.com/${widget.playerUrl}'));
    final document = parser.parse(response.body);

    // Identify the table based on a unique attribute (class, ID, etc.)
    final table = document.getElementsByClassName('table cb-col-100 cb-plyr-thead'); // Replace with the actual class name or ID
    playerName = document.getElementsByClassName('cb-font-40').first.text;
    playerDpUrl = document.getElementsByClassName('cb-col cb-col-20 cb-col-rt').first.getElementsByTagName('img').first.attributes['src']!;
    if (table != null) {
      final battingRows = table.first.querySelectorAll('tr');
      final bowlingRows = table.last.querySelectorAll('tr');

      for (final row in battingRows) {
        final cells = row.children.where((e) => e.localName == 'td' || e.localName == 'th');
        final rowList = cells.map((cell) => cell.text).toList();
        battingTable.add(rowList);
      }

      for (final row in bowlingRows) {
        final cells = row.children.where((e) => e.localName == 'td' || e.localName == 'th');
        final rowList = cells.map((cell) => cell.text).toList();
        bowlingTable.add(rowList);
      }
    }
    setState(() {
      tableToShow = battingTable;
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parsePlayerStats();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
            height: size.height,
            width: size.width,
            child: tableToShow.isNotEmpty? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://www.cricbuzz.com$playerDpUrl'),
                      ),
                      const SizedBox(width: 10,),
                      Text(playerName, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 20),)
                    ],
                  ),
                ),
                SizedBox(height: size.height*0.02,),
                GestureDetector(
                  onTap: ()=> handleTableChange(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(FontAwesomeIcons.solidArrowAltCircleLeft, color: Color(0xffFE00A8),),
                      Text(tableName[tableNameIndex], style: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontSize: 20),),
                      const Icon(FontAwesomeIcons.solidArrowAltCircleRight, color: Color(0xffFE00A8),),
                    ],
                  ),
                ),
                SizedBox(height: size.height*0.02,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(tableToShow.length, (index){
                    return Column(
                      children: List.generate(tableToShow[index].length, (index1){
                        final object = tableToShow[index][index1];
                        return Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: size.width/7,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: object.isNotEmpty? Colors.grey[800]: Colors.black,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(object, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                        );
                      }),
                    );
                  }),
                )
              ],
            ) :
            const Center(
              child: CircularProgressIndicator(color: Color(0xffFE00A8),),
            )
        )
    );
  }
}
