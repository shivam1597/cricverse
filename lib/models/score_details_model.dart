class ScoreDetailsModel{
  List<Map<String, dynamic>>? ballComments; // fetch only 18 items (content-> recentBallCommentary-> ballComments) only available for live match or else null
  List<Map<String, dynamic>>? superOverBallComments;
  List<dynamic>? firstInningBatsmen; // content->matchPlayers->teamPlayers[0](for team1) ->players and fetch all
  List<dynamic>? firstInningBowlers;
  // find them under innings
  List<dynamic>? firstInningsWicket;
  List<dynamic>? firstInningFallOfWickets;
  Map<String, dynamic>? firstInningsTeam;
  List<dynamic>? secondInningBatsmen; // content->matchPlayers->teamPlayers[0](for team1) ->players and fetch all
  List<dynamic>? secondInningBowlers;
  // find them under innings
  List<dynamic>? secondInningsWicket;
  List<dynamic>? secondInningFallOfWickets;
  Map<String, dynamic>? secondInningsTeam;

  ScoreDetailsModel({this.ballComments, this.firstInningFallOfWickets, this.firstInningsTeam,
    this.firstInningsWicket, this.firstInningBatsmen, this.firstInningBowlers, this.secondInningFallOfWickets, this.secondInningsTeam,
    this.secondInningsWicket, this.secondInningBatsmen, this.secondInningBowlers, this.superOverBallComments
  });
}