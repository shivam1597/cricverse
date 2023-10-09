import 'package:cricverse/models/ranking_models.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class RankingProvider extends ChangeNotifier{
  List<RankingModel> ranking = [];
  String rankUrl = 'https://www.crictracker.com/_next/data/{api-id}/en/icc-rankings/teams-t20i.json?type=teams-t20i';
  String currentRankingLabel = 'T20I Team';
  List<String> formatList = ['Test', 'ODI', 'T20I'];
  List<String> rankTypeList = ['Teams', 'Bowling', 'Batting', 'All Rounder'];
  String selectedFormat = 'Test';
  String selectedRankType = 'Teams';
  List<RankingModel> testRankings = [];
  List<RankingModel> odiRankings = [];
  List<RankingModel> t20iRankings = [];
  List<RankingModel> rankingToShow = [];

  void fetchTeamRanking()async{
    var response = await http.get(Uri.parse('https://www.cricbuzz.com/cricket-stats/icc-rankings/men/teams'));
    final document = parse(response.body);
    final allRankingContainers = document.getElementsByClassName('cb-col cb-col-100 cb-padding-left0');
    final testRankingElements = allRankingContainers[0].getElementsByClassName('cb-col cb-col-100 cb-font-14 cb-brdr-thin-btm text-center');
    final odiRankingElements = allRankingContainers[1].getElementsByClassName('cb-col cb-col-100 cb-font-14 cb-brdr-thin-btm text-center');
    final t20iRankingElements = allRankingContainers[2].getElementsByClassName('cb-col cb-col-100 cb-font-14 cb-brdr-thin-btm text-center');
    for(var v in testRankingElements){
      addTeamsToList(v, testRankings);
    }
    for(var v in odiRankingElements){
      addTeamsToList(v, odiRankings);
    }
    for(var v in t20iRankingElements){
      addTeamsToList(v, t20iRankings);
    }
    rankingToShow = testRankings;
    notifyListeners();
  }

  void addTeamsToList(v, listName){
    final teamName = v.getElementsByTagName('div')[1].text;
    final teamRating = v.getElementsByTagName('div')[2].text;
    final teamPoints = v.getElementsByTagName('div')[3].text;
    RankingModel rankingModel = RankingModel(
      title: teamName, points: teamPoints, rating: teamRating
    );
    listName.add(rankingModel);
  }

  void fetchPlayerRanking()async{
    var response = await http.get(Uri.parse('https://www.cricbuzz.com/cricket-stats/icc-rankings/men/${selectedRankType.toLowerCase().replaceAll(' ', '-')}'));
    final document = parse(response.body);
    final namesElement = document.getElementsByClassName('cb-col cb-col-67 cb-rank-plyr');
    final ratingsElement = document.getElementsByClassName('cb-col cb-col-17 cb-rank-tbl pull-right');
    final dpUrlElement = document.getElementsByClassName('cb-col cb-col-33');
    int i = 0;
    for(var v in namesElement){
      if(i<10){
        addPlayersToRankingList(v, namesElement, ratingsElement, dpUrlElement, testRankings);
      } else if(i>9&&i<20){
        addPlayersToRankingList(v, namesElement, ratingsElement, dpUrlElement, odiRankings);
      } else if(i>19&&i<30){
        addPlayersToRankingList(v, namesElement, ratingsElement, dpUrlElement, t20iRankings);
      }
      i++;
    }
    notifyListeners();
  }

  void addPlayersToRankingList(v, namesElement, ratingsElement, dpUrlElement, listName){
    int index = namesElement.indexOf(v);
    final name = v.getElementsByTagName('a').first.text;
    final playerDetailsUrl = v.getElementsByTagName('a').first.attributes['href'];
    final playerCountry = v.getElementsByTagName('div').first.text.trim();
    final rating = ratingsElement[index].text.trim();
    final changeInRanks = dpUrlElement[index].getElementsByClassName('cb-col cb-col-50').first.text.trim();
    final playerDpUrl = dpUrlElement[index].getElementsByClassName('cb-col cb-col-50').last.getElementsByTagName('img').first.attributes['src'];
    RankingModel rankingModel = RankingModel(
      title: name, rating: rating, dpUrl: playerDpUrl, country: playerCountry, profileUrl: playerDetailsUrl, changeInRanks: changeInRanks
    );
    listName.add(rankingModel);
  }

  void handleFormatChange(String formatType){
    selectedFormat = formatType;
    if(selectedFormat=='Test'){
      rankingToShow = testRankings;
    } else if(selectedFormat=='ODI'){
      rankingToShow = odiRankings;
    } else if(selectedFormat=='T20I'){
      rankingToShow = t20iRankings;
    }
    notifyListeners();
  }

  void handleRankingTypeChange(String type){
    testRankings.clear();
    t20iRankings.clear();
    odiRankings.clear();
    notifyListeners();
    selectedRankType = type;
    if(type=='Teams'){
      fetchTeamRanking();
    }
    else{
      fetchPlayerRanking();
    }
  }

}