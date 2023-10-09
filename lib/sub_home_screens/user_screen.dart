import 'dart:async';

import 'package:cricverse/app_info_screens/about_screen.dart';
import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:cricverse/bcci_screens/bcci_videos.dart';
import 'package:cricverse/app_info_screens/privacy_policy.dart';
import 'package:cricverse/providers/score_providers.dart';
import 'package:cricverse/providers/user_details_provider.dart';
import 'package:cricverse/sub_home_screens/meme_templates_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../news_screens/news_screen.dart';

class UserScreen extends StatelessWidget {
  ScoreProvider? scoreProvider;
  UserScreen({this.scoreProvider, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child){
        return Container(
          height: size.height,
          width: size.width*0.65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.7)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ListTile(
              //   title: Text(userDetailsProvider.userDisplayName, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 20),),
              //   subtitle: Text(userDetailsProvider.userEmail, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 10),),
              //   trailing: userDetailsProvider.nameRefreshProgress? const SizedBox(
              //     height: 30,
              //     width: 30,
              //     child: CircularProgressIndicator(color: Color(0xffFE00A8),),
              //   ) :IconButton(
              //     onPressed: ()=> userDetailsProvider.updateUserName(),
              //     icon: const Icon(Icons.refresh, color: Colors.white60,),
              //   ),
              // ),
              ListTile(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const NewsScreen())),
                leading: const Icon(FontAwesomeIcons.newspaper, color: Colors.white70,),
                title: Text('Cricket News', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              ListTile(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const MemeTemplatesList())),
                leading: const Icon(FontAwesomeIcons.laughSquint, color: Colors.white70,),
                title: Text('Choose Templates.\nCreate Cricket Memes', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              ListTile(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const BcciVideos())),
                leading: const Icon(FontAwesomeIcons.video, color: Colors.white70,),
                title: Text('Videos', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                subtitle: Text('By BCCI', style: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontWeight: FontWeight.w300, fontSize: 12),),
              ),
              // userDetailsProvider.usedReferralCode=='code_not_used'?ListTile(
              //     // onTap: ()=> userDetailsProvider.verifyReferralCode('qwerty'),
              //     onTap:()=> userDetailsProvider.showReferralDialog(context),
              //     leading: const Icon(FontAwesomeIcons.coins, color: Colors.white70,),
              //     title: Text('Have a referral code?', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              //     subtitle: Text('Redeem here', style: GoogleFonts.poppins(color: const Color(0xffFE00A8), fontWeight: FontWeight.w400, fontSize: 13),)
              // ):const Center(),
              // ListTile(
              //   leading: const Icon(Icons.payment, color: Colors.white70,),
              //   title: Text('Payouts will be available soon!', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              // ),
              ListTile(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const AboutCricVerseScreen())),
                leading:  const Icon(Icons.info, color: Colors.white70,),
                title: Text('About CricVerse', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              ListTile(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const PrivacyPolicyScreen())),
                leading: const Icon(FontAwesomeIcons.userSecret, color: Colors.white70,),
                title: Text('Privacy Policy', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              ListTile(
                onTap: ()async=> launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.cricverse.android')),
                leading: const Icon(FontAwesomeIcons.gratipay, color: Colors.white70,),
                title: Text('Rate Us', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              ListTile(
                onTap: ()=> Share.share('Get CricVerse and experience cricket like never before. https://play.google.com/store/apps/details?id=com.cricverse.android'),
                leading: const Icon(FontAwesomeIcons.share, color: Colors.white70,),
                title: Text('Share', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
              ),
              userDetailsProvider.updateAvailable?ListTile(
                onTap: ()=> launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.cricverse.android')),
                leading: const Icon(Icons.update, color: Colors.white70,),
                title: Text('Update Available', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                trailing: Icon(Icons.download, color: Colors.red[400],),
              ):const Center(),
              const BannerAdWidget()
            ],
          ),
        );
      },
    );
  }

}
