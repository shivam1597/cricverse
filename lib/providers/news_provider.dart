import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cricverse/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsProvider extends ChangeNotifier{
  List<Map<String, String>> newsList = [];
  List<dynamic> newsUrlsList = [];
  List<NewsModel> cwcNewsList = [];
  bool pageLoading = false;
  int pageNumber = 1;
  int cwcNewsPageNumber = 0;
  int newsOffSet = 11;

  void handlePageChange()async{
    pageLoading = true;
    notifyListeners();
    newsOffSet = newsOffSet+10;
    fetchNews();
  }

  void takeScreenShotAndShare(GlobalKey itemKey, String url, String title)async{
    RenderRepaintBoundary boundary =
    itemKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await Future.delayed(const Duration(seconds: 2));
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();
    var directory = await getApplicationCacheDirectory();
    File file = File('${directory.path}/ss-to-share.png');
    await file.writeAsBytes(uint8List);
    Share.shareFiles(['${directory.path}/ss-to-share.png'], text: '$title\n$url');
  }

  void fetchCWCNews()async{
    var response = await http.get(Uri.parse('https://content-icc.pulselive.com/content/icc/text/en/?page=$cwcNewsPageNumber&pageSize=60&onlyRestrictedContent=false&references=&tagNames=News%2CCricket%20World%20Cup'));
    var jsonObject = json.decode(response.body);
    for(var v in jsonObject['content']){
      NewsModel newsModel = NewsModel(
        title: v['title'], publishedTime: v['date'], thumbnail: v['imageUrl'], url: 'https://www.cricketworldcup.com/news/${v['id']}',
        subtitle: v['subtitle']
      );
      cwcNewsList.add(newsModel);
    }
    notifyListeners();
  }

  void fetchNews()async{
    final response = await http.get(Uri.parse('https://www.bing.com/news/infinitescrollajax?qft=sortbydate%3d%221%22&form=YFNR&InfiniteScroll=1&q=cricket%20news&first=$newsOffSet&IG=57F1C5646D8A4B66BF0D0A77AEB75D2E&IID=news.5264&SFX=0&PCW=1011'));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final newsCards = document.querySelectorAll('.news-card');

      for (final card in newsCards) {
        final title = card.querySelector('.title')?.text;
        final url = card.attributes['url'];
        final author = card.querySelector('.title')?.attributes['data-author'];
        final snippet = card.querySelector('.snippet')?.text;
        final timeAgo = card.querySelector('.t_t span[aria-label]')?.text;
        final authorLogo = card.querySelector('.author-logo img')?.attributes['src'];

        String imageUrl = ''; // Initialize imageUrl as an empty string

        // Check for the presence of the "image right" class and extract the image URL
        final imageRightElement = card.querySelector('.image.right');
        if (imageRightElement != null) {
          final imageElement = imageRightElement.querySelector('img');
          if (imageElement != null) {
            imageUrl = imageElement.attributes['src']!;
          }
        }

        if (title != null && url != null) {
          Map<String, String> mapToAdd = {
            'title': title,
            'url': url,
            'author': author ?? 'Unknown',
            'snippet': snippet ?? '',
            'timeAgo': timeAgo ?? '',
            'authorLogo': authorLogo ?? '',
            'imageUrl': imageUrl, // Store the image URL
          };
          newsList.add(mapToAdd);
        }
      }
    }
    if(newsOffSet==11){
      Future.delayed(const Duration(seconds: 5)).then((value){
        handlePageChange();
      });
    }
    pageLoading = false;
    notifyListeners();
  }
}