import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutCricVerseScreen extends StatelessWidget {
  const AboutCricVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40,),
            _buildHeading('About CricVerse'),
            _buildParagraph(
              'CricVerse',
            ),
            _buildParagraph(
              'Discover the world of cricket with CricVerse, the ultimate app for cricket enthusiasts. Get the latest cricket news, live scores, rankings, video highlights, fixtures, and player insights—all in one place. Join our vibrant fan community, trade virtual player coins, and never miss a moment of the action. Plus, connect with fellow cricket fans on Reddit for even more discussion and insights. With real-time updates and a user-friendly interface, CricVerse brings cricket to life at your fingertips.',
            ),
            _buildParagraph(
              'Download CricVerse today and immerse yourself in the cricketing world!',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white70
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white70),),
    );
  }
}
