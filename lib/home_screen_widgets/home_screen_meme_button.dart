import 'package:cricverse/sub_home_screens/meme_templates_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenMemeButton extends StatelessWidget {
  Size size;
  HomeScreenMemeButton(this.size, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const MemeTemplatesList())),
      child: Container(
        height: 55,
        width: size.width,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10, left: 10),
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffFE00A8)),
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff310072)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.laughSquint, size: 35, color: Colors.white,),
            const SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose templates. Create Cricket memes.', style: GoogleFonts.albertSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),),
                const SizedBox(height: 2.5,),
                Text("Tap to explore>>>", style: GoogleFonts.albertSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),)
              ],
            )
          ],
        ),
      ),
    ); // meme widget;
  }
}
