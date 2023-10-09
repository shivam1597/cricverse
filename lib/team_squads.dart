import 'package:cricverse/providers/score_providers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TeamSquad extends StatefulWidget {
  String url;
  String statusText;
  String date;
  TeamSquad(this.url, this.statusText, this.date, {Key? key}) : super(key: key);

  @override
  State<TeamSquad> createState() => _TeamSquadState();
}

class _TeamSquadState extends State<TeamSquad> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<ScoreProvider>(context, listen: false);
      provider.fetchTeamSquad(widget.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(
      builder: (context, scoreProvider, child){
        return DefaultTabController(
          length: scoreProvider.squadPlayersList.length,
          child: scoreProvider.squadPlayersList.isNotEmpty? Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Column(
                children: [
                  Text(widget.statusText, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(widget.date, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              centerTitle: true,
              bottom: TabBar(
                indicatorColor: const Color(0xffFE00A8),
                tabs: [
                  Tab(
                    text: scoreProvider.squadPlayersList.first.keys.first,
                  ),
                  Tab(
                    text: scoreProvider.squadPlayersList.last.keys.first,
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    ...scoreProvider.squadPlayersList.first.entries.map((e){
                      List<dynamic> playerMap = e.value;
                      return Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: List.generate(playerMap.length, (index){
                            return ListTile(
                              title: Text('${playerMap[index]['player']['name']} ${playerMap[index]['playerRoleType']!='P'?'(${playerMap[index]['playerRoleType']})':''}',
                                style: GoogleFonts.poppins(color: Colors.white70),
                              ),
                            );
                          }),
                        ),
                      );
                    })
                  ],
                ),
                Column(
                  children: [
                    ...scoreProvider.squadPlayersList.last.entries.map((e){
                      List<dynamic> playerMap = e.value;
                      return Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: List.generate(playerMap.length, (index){
                            return ListTile(
                              title: Text('${playerMap[index]['player']['name']} ${playerMap[index]['playerRoleType']!='P'?'(${playerMap[index]['playerRoleType']})':''}',
                                style: GoogleFonts.poppins(color: Colors.white70),
                              ),
                            );
                          }),
                        ),
                      );
                    })
                  ],
                ),
              ],
            ),
          )
              : scoreProvider.squadEmpty?
               Scaffold(
                 backgroundColor: Colors.black,
                 body: Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(FontAwesomeIcons.sadCry, color: Color(0xffFE00A8), size: 60,),
                       const SizedBox(height: 20,),
                       Text('Squad not available', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 20),)
                     ],
                   ),
                 ),
               )
              :const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
        );
      },
    );
  }
}
