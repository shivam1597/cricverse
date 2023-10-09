import 'package:cricverse/flag_asset/all_icc_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
class TeamSquad extends StatefulWidget {
  String matchId;
  TeamSquad(this.matchId, {Key? key}) : super(key: key);

  @override
  State<TeamSquad> createState() => _TeamSquadState();
}

class _TeamSquadState extends State<TeamSquad> {

  Map<String, dynamic> teamSquads = {};

  void fetchTeamSquad()async{
    var response = await http.get(Uri.parse('https://www.cricketworldcup.com/match/${widget.matchId}'));
    var document = parse(response.body);
    final teamNames = document.getElementsByClassName('long');
    final team1SquadList = document.getElementsByClassName('mc-squad-list mc-squad-list--home');
    final team2SquadList = document.getElementsByClassName('mc-squad-list mc-squad-list--away');
    
    final team1PlayersElement = team1SquadList.first.getElementsByClassName('mc-squad-list__player js-player');
    final team2PlayersElement = team2SquadList.first.getElementsByClassName('mc-squad-list__player js-player');
    List<String> team1Players = [];
    List<String> team2Players = [];
    for(final member in team1PlayersElement){
      final String playerName = member.getElementsByClassName('mc-squad-list__player-name js-full-name').first.text.trim();
      team1Players.add(playerName);
    }
    for(final member in team2PlayersElement){
      final String playerName = member.getElementsByClassName('mc-squad-list__player-name js-full-name').first.text.trim();
      team2Players.add(playerName);
    }
    teamSquads[teamNames.first.text] = team1Players;
    teamSquads[teamNames.last.text] = team2Players;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTeamSquad();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Squads', style: GoogleFonts.cabin(color: Colors.white, fontWeight: FontWeight.w600),),
      ),
      body: teamSquads.isNotEmpty? SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      SvgPicture.network(flagUrlMap[teamSquads.keys.first]!, height: 40,),
                      const SizedBox(width: 10,),
                      Text(teamSquads.keys.first, style: GoogleFonts.poppins(color: Colors.white70),),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.network(flagUrlMap[teamSquads.keys.last]!, height: 40,),
                      const SizedBox(width: 10,),
                      Text(teamSquads.keys.last, style: GoogleFonts.poppins(color: Colors.white70),),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: teamSquads.values.first.length,
                separatorBuilder: (context, index){
                  return const Divider(height: 2, color: Colors.grey,);
                },
                itemBuilder: (context, index){
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('${teamSquads.values.first[index]}', style: GoogleFonts.poppins(color: Colors.white70),),
                        Text('${teamSquads.values.last[index]}', style: GoogleFonts.poppins(color: Colors.white70),)
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        )
      ): const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
    );
  }
}
