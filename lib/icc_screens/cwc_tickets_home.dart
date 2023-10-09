import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/providers/cwc_tickets_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CwcTicketsHome extends StatelessWidget {
  const CwcTicketsHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<CwcTicketProvider>(
      builder: (context, cwcTicketProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text('Find By Team', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),),
                const SizedBox(height: 15,),
                SizedBox(
                  height: size.height*0.65,
                  child: cwcTicketProvider.countryTicketMap.isNotEmpty? GridView.count(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      ...cwcTicketProvider.countryTicketMap.entries.map((e){
                        return GestureDetector(
                          onTap: ()async=> await launchUrl(Uri.parse(e.value)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(e.key),
                          ),
                        );
                      })
                    ],
                  ) 
                      : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
                ),
                const BannerAdWidget(),
                Text('Search By Stadium', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),),
                SizedBox(
                  height: 150,
                  width: size.width,
                  child: cwcTicketProvider.stadiumTicketMap.isNotEmpty? ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...cwcTicketProvider.stadiumTicketMap.entries.map((e){
                        return GestureDetector(
                          onTap: ()async=> await launchUrl(Uri.parse(e.value)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              child: Image.network(e.key),
                            ),
                          ),
                        );
                      })
                    ],
                  )
                      : const Center(child: CircularProgressIndicator(color: Color(0xffFE00A8),),),
                )
              ],
            ),
          )
        );
      },
    );
  }
}
