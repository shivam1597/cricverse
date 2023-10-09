import 'dart:convert';
import 'package:cricverse/providers/ticket_json_string.dart';
import 'package:flutter/material.dart';

class CwcTicketProvider extends ChangeNotifier{

  Map<String, String> countryTicketMap = {};
  Map<String, String> stadiumTicketMap = {};
  List<Map<String, String>> ticketsList = [];

  void fetchCwcTickets()async{
    var jsonObject = json.decode(ticketJsonString);
    for(var v in jsonObject['listings']){
      if(v['id']=='CWC_TEAM_MATCHES_WEB'){
        for(var card in v['cards']){
          String imageUrl = card['image']['url'];
          String ticketUrl = card['ctaUrl'];
          countryTicketMap[imageUrl]=ticketUrl;
        }
      }
      /// parsing stadiums
      if(v['id']=='CWC_STADIUMS_WEB'){
        for(var card in v['cards']){
          String imageUrl = card['image']['url'];
          String ticketUrl = card['ctaUrl'];
          stadiumTicketMap[imageUrl]=ticketUrl;
        }
        break;
      }
    }
    notifyListeners();
  }
}