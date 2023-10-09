import 'package:cricverse/providers/news_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsBrowser extends StatefulWidget {
  String newsUrl;
  NewsBrowser(this.newsUrl, {Key? key}) : super(key: key);

  @override
  State<NewsBrowser> createState() => _NewsBrowserState();
}

class _NewsBrowserState extends State<NewsBrowser> {

  String iconUrl = '';

  Future<void> _fetchFaviconUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.newsUrl));
      final document = html_parser.parse(response.body);
      final faviconTag = document.querySelector("link[rel*='icon']") ?? document.querySelector("link[rel='shortcut icon']");
      if (faviconTag != null) {
        final href = faviconTag.attributes['href'];
        print(href);
        if (href != null && href.isNotEmpty) {
          if(href.contains('https://')){
            setState(() {
              iconUrl = href;
            });
          }else{
            setState(() {
              iconUrl = 'https://${Uri.parse(widget.newsUrl).host}$href';
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching favicon: $e");
    }
  }

  late WebViewController webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchFaviconUrl();
  }

  @override
  Widget build(BuildContext context) {
    print(iconUrl);
    return Consumer<NewsProvider>(
      builder: (context, provider, child){
        return SafeArea(
          child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: WebView(
                      onWebViewCreated: (controller){
                        webViewController = controller;
                      },
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: widget.newsUrl,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        !iconUrl.contains('.svg')?CircleAvatar(
                          radius: 15,
                          backgroundImage: iconUrl.isNotEmpty? NetworkImage(iconUrl): const NetworkImage('https://placekitten.com/200/300'),
                        ): SvgPicture.network(iconUrl),
                        // Text('News Source: ${widget.newsSource}', style: GoogleFonts.poppins(color: context.isDarkMode?Colors.white:Colors.black, fontWeight: FontWeight.w700),),
                        GestureDetector(
                          onTap: ()async{
                            await launchUrl(Uri.parse(Uri.parse(widget.newsUrl).origin), mode: LaunchMode.externalApplication);
                          },
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300] as Color),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.open_in_new, color: Colors.white, size: 20,),
                                Text('  ${Uri.parse(widget.newsUrl).host.replaceAll('www.', '')}', style: GoogleFonts.b612(color: Colors.white),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
          ),
        );
      },
    );
  }
}
