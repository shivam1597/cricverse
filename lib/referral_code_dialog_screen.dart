import 'package:cricverse/providers/user_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReferralCodeScreen extends StatelessWidget {
  const ReferralCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child){
        return SizedBox(
          height: 190,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userDetailsProvider.textEditingController,
                style: GoogleFonts.poppins(color: Colors.white70),
                decoration: InputDecoration(
                  hintText: 'Enter referral code here',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // Adjust the value to control the roundness
                    borderSide: BorderSide(color: const Color(0xFFFE00A8).withOpacity(0.7), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the value to control the roundness
                      borderSide: BorderSide(color: const Color(0xFFFE00A8).withOpacity(0.7), width: 2.0)
                  ),
                ),
                cursorColor: Colors.white70,
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: ()=> userDetailsProvider.verifyReferralCode(),
                child: Container(
                  alignment: Alignment.center,
                  height: 45,
                  width: size.width*0.5,
                  decoration: BoxDecoration(
                      color: const Color(0xffFE00A8),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Text('Verify', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),),
                ),
              ),
              const SizedBox(height: 15,),
              userDetailsProvider.verificationInProgress?const Center(
                child: CircularProgressIndicator(color: Color(0xffFE00A8),),
              ): const Center(),
              Text(userDetailsProvider.referralVerificationMessage.isEmpty?'':userDetailsProvider.referralVerificationMessage,
                style: GoogleFonts.poppins(color: Colors.red[600], fontWeight: FontWeight.w700),
              )
            ],
          ),
        );
      },
    );
  }
}
