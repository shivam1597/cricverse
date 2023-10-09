import 'package:cricverse/referral_code_dialog_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class UserDetailsProvider extends ChangeNotifier{

  bool nameRefreshProgress = false;
  bool updateAvailable = false;
  String usedReferralCode = '';
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool verificationInProgress = false;
  String referralVerificationMessage = '';
  final TextEditingController textEditingController = TextEditingController();

  void handleNameUpdate(){
    nameRefreshProgress = !nameRefreshProgress;
    notifyListeners();
  }


  void verifyUpdate()async{
    final box = await Hive.openBox('myBox');
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference databaseReference = firebaseDatabase.ref();
    var data = await databaseReference.child('update_available').once();
    if(data.snapshot.value!=null){
      updateAvailable = data.snapshot.value as bool;
    }
    // var referralCheckData = await databaseReference.child('referral_used').child(box.get('user_id')).once();
    // if(box.get('used_referral_code')!=null){
    //   usedReferralCode = box.get('used_referral_code');
    // }else{
    //   var referralCheckData = await databaseReference.child('referral_used').child(box.get('user_id')).once();
    //   if(referralCheckData.snapshot.value!=null){
    //     box.put('used_referral_code', referralCheckData.snapshot.value);
    //   }else{
    //     box.put('used_referral_code', 'code_not_used');
    //     usedReferralCode = 'code_not_used';
    //   }
    // }
    notifyListeners();
  }

  void verifyReferralCode()async{
    String referralCode = textEditingController.text;
    referralVerificationMessage = '';
    verificationInProgress = true;
    notifyListeners();
    final box = await Hive.openBox('myBox');
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference databaseReference = firebaseDatabase.ref();
    DatabaseEvent databaseEvent = await databaseReference.child('referral_codes').child(referralCode).once();
    if(databaseEvent.snapshot.value!=null){
      Map<Object?, Object?> referralMap = databaseEvent.snapshot.value as Map<Object?, Object?>;
      String referralCodeOwnerUserId = referralMap['uid'].toString();
      String referredUserCount = referralMap['user_count'].toString();
      int userCount = int.parse(referredUserCount)+1;
      String myUserId = box.get('user_id');
      // updating data in referral_code node
      databaseReference.child('referral_codes').child(referralCode).update({
        'uid':referralCodeOwnerUserId,
        'user_count':userCount
      });
      // updating data in user node
      databaseReference.child('referral_used').update({
        myUserId:referralCode
      });
      usedReferralCode = referralCode;
      await box.put('used_referral_code', referralCode);
      await box.put('timeSpent', 1800);
      Fluttertoast.showToast(msg: 'Code has been redeemed');
    }
    else{
      referralVerificationMessage = 'The code you have entered is incorrect!';
    }
    verificationInProgress = false;
    textEditingController.clear();
    notifyListeners();
  }

  showReferralDialog(context1){
    showDialog(
      context: context1,
      builder: (context1){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.grey[900],
          content: const ReferralCodeScreen(),
        );
      }
    );
  }
}