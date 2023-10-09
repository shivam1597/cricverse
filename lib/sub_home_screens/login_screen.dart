import 'dart:math';

import 'package:cricverse/home_screen_widgets/home_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  bool? isLoggedIn;
  
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // void signInUser()async{
  //   DatabaseReference databaseReference = firebaseDatabase.ref();
  //   final box = await Hive.openBox('myBox');
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  //     if (googleSignInAccount != null) {
  //       final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleSignInAuthentication.accessToken,
  //         idToken: googleSignInAuthentication.idToken,
  //       );
  //       final UserCredential authResult = await _auth.signInWithCredential(credential);
  //       final User? user = authResult.user;
  //       box.put('email', user!.email);
  //       box.put('name', user.displayName);
  //       box.put('user_id', user.uid);
  //       databaseReference.child('users').child(user.uid).update(
  //         {
  //           'name': user.displayName,
  //           'email': user.email,
  //           'user_id': user.uid
  //         }
  //       );
  //       databaseReference.child('referral_codes').child(user.uid.substring(0,6)).update({
  //         'uid':user.uid,
  //         'user_count':'0'
  //       });
  //       if(mounted){
  //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
  //       }
  //     }
  //   } catch (error) {
  //     print(error);
  //     return null;
  //   }
  // }
  //
  // void checkLogin(){
  //   Hive.openBox('myBox').then((box){
  //     final email = box.get('email');
  //     if(email!=null){
  //
  //     }
  //     else{
  //       setState(() {
  //         isLoggedIn = false;
  //       });
  //     }
  //   });
  // }

  String generateExternalUserId() {
    final random = Random();
    final codeUnits = List.generate(
      20,
          (index) {
        return random.nextInt(26) + 65; // Generates random uppercase letters
      },
    );
    return String.fromCharCodes(codeUnits);
  }

  void checkFirstTime()async{
    final box = await Hive.openBox('myBox');
    if(box.get('userID')!=null){
      if(mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
      }
    }else{
      String cricverseAppId = 'FMCHWLKRMUELZOIYEHDT';
      var deviceInfo = await DeviceInfoPlugin().androidInfo;
      String registeredId = '$cricverseAppId${deviceInfo.id}';
      OneSignal.initialize('a6803967-4276-4785-bdda-d48455ed72dc');
      OneSignal.login(registeredId);
      box.put('userID', registeredId);
      OneSignal.Notifications.requestPermission(true);
      if(mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value){
      checkFirstTime();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/cric_verse_icon.png', height: 90,),
            SizedBox(
              height: size.height*0.4,
            ),
            const Center(
              child: CircularProgressIndicator(color: Color(0xffFE00A8),),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
