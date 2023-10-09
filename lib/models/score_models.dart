class ScoreModel{
  List<dynamic>? team1Innings;
  List<dynamic>? team2Innings;
  String? matchId;
  String? stage;
  String? matchObjectId; // change to string
  String? matchSlug;
  String? state; // POST state
  String? title;
  String? floodlit;
  String? startDate;
  String? endDate;
  String? startTime;
  bool? isCancelled;
  String? status;
  String? statusText;
  String? liveOvers;
  String? seriesId;
  String? seriesName;
  String? seriesObjectId;
  String? seriesSlug;
  String? seriesStartDate;
  String? seriesEndDate;
  String? stadium;
  String? stadiumImage;
  String? team1Name;
  String? team1Abbr;
  String? team1FlagUrl;
  String? team1Score; // can be null
  String? team1ScoreInfo;
  String? team2Name;
  String? team2Abbr;
  String? team2FlagUrl;
  String? team2Score;
  String? team2ScoreInfo;
  String? dayType;
  String? format;
  bool? isSuperOver;
  ScoreModel({
    this.team1Innings,
    this.team2Innings,
    this.matchObjectId,
    this.title,
    this.status,
    this.format,
    this.dayType,
    this.endDate,
    this.floodlit,
    this.isCancelled,
    this.isSuperOver,
    this.liveOvers,
    this.matchId,
    this.seriesObjectId,
    this.seriesEndDate,
    this.seriesName,
    this.seriesStartDate,
    this.stadium,
    this.stadiumImage,
    this.stage,
    this.startDate,
    this.startTime,
    this.state,
    this.statusText,
    this.team1FlagUrl,
    this.team1Name,
    this.team1Abbr,
    this.team1Score,
    this.team1ScoreInfo,
    this.team2FlagUrl,
    this.team2Name,
    this.team2Abbr,
    this.team2Score,
    this.team2ScoreInfo,
});
}
//https://hs-consumer-api.espncricinfo.com/v1/pages/match/scorecard?lang=en&seriesId=1388374&matchId=1388400 -> full score card