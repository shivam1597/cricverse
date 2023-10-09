import 'package:cricverse/coin_player_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class CoinsProvider extends ChangeNotifier{
  
  FirebaseDatabase database = FirebaseDatabase.instance;
  Map<Object?, Object?>? coinSnapshot;
  bool inProgress = false;
  Map<Object?, Object?> purchasedCoins = {};
  Map<String, String> coinsValueMap = {};
  String textFieldAmount = '';

  void updateCoinsValueMap(String coinName, String timeStamp)async{
    DatabaseReference databaseReference = database.ref();
    var dbEvent = await databaseReference.child('cricto_coins').child(coinName).child('initial_value').once();
    String updatedValue = dbEvent.snapshot.value.toString();
    coinsValueMap[timeStamp] = updatedValue;
    notifyListeners();
  }

  void getCoins()async{
    DatabaseReference databaseReference = database.ref();
    var databaseEvent = await databaseReference.child('cricto_coins').once();
    coinSnapshot = databaseEvent.snapshot.value as Map<Object?, Object?>;
    notifyListeners();
  }

  void handleProgress(){
    inProgress = !inProgress;
    notifyListeners();
  }

  void fetchPurchasedCoins()async{
    final box = await Hive.openBox('myBox');
    String uid = box.get('user_id');
    DatabaseReference databaseReference = database.ref();
    var dbEvent = await databaseReference.child('coins_purchased').child(uid).once();
    purchasedCoins = dbEvent.snapshot.value as Map<Object?, Object?>;
    notifyListeners();
  }
  
  Future<void> updateCoinValue(String coinName, double availableBalance, String coinValueString, String uid, context)async{
    double enteredAmount = double.parse(textFieldAmount);
    double coinValue = double.parse(coinValueString);
    double percentageOwned = (enteredAmount/coinValue)*100;
    if(enteredAmount<=availableBalance&&enteredAmount>0){
      notifyListeners();
      handleProgress();
      Navigator.pop(context);
      DatabaseReference databaseReference = database.ref();
      var initialValue = await databaseReference.child('cricto_coins').child(coinName).child('initial_value').once();
      var purchaseCountObject = await databaseReference.child('cricto_coins').child(coinName).child('purchase_count').once();
      double currentCoinValue = double.tryParse(initialValue.snapshot.value.toString())!;
      var purchaseCountString = purchaseCountObject.snapshot.value??0;
      double purchaseCount = double.parse(purchaseCountString.toString());
      // purchased value will be the amount entered in the textfield
      double updatedValue = currentCoinValue+enteredAmount;
      double updatedPurchaseCount = purchaseCount + 1;
      // updating coin value
      await databaseReference.child('cricto_coins').child(coinName).child('initial_value').set(updatedValue);
      // updating purchase count
      await databaseReference.child('cricto_coins').child(coinName).child('purchase_count').set(updatedPurchaseCount);
      // updating coins in user's account
      await databaseReference.child('coins_purchased').child(uid).child(DateTime.now().millisecondsSinceEpoch.toString()).update({
        'coin_name': coinName,
        'coin_value_during_purchase': coinValue,
        'percentage_owned': percentageOwned
      });
      final box = await Hive.openBox('myBox');
      int seconds = box.get('timeSpent');
      int secondsSpentByUser = (enteredAmount!*60*100).toInt();
      box.put('timeSpent', seconds-secondsSpentByUser);
      Fluttertoast.showToast(msg: 'Your purchase has been updated.');
      handleProgress();
    }else{
      Fluttertoast.showToast(msg: 'Not enough balance.');
    }
  }

  void handleTextChange(String value){
    textFieldAmount = value;
    notifyListeners();
  }

  void confirmationDialog(context, String coinValue, String coinName, Size size, String playerUrl)async{
    final box = await Hive.openBox('myBox');
    int seconds = box.get('timeSpent');
    double points = seconds/60;
    double availableBalance = points/100; // balance in inr
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.grey[900],
          content: SizedBox(
            height: 268,
            width: size.width,
            child: Stack(
              children: [
                Column(
                  children: [
                    Text(coinName, style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 24),),
                    const SizedBox(height: 30,),
                    Text('Coin Value: $coinValue', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                    const SizedBox(height: 20,),
                    Text('Your balance: ₹${availableBalance.toString().substring(0,4)}', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
                    const SizedBox(height: 30,),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: TextField(
                        style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                        cursorColor: Colors.grey[400],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Amount',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        onChanged: handleTextChange,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: ()=> updateCoinValue(coinName, availableBalance, coinValue, box.get('user_id'), context),
                          child: Container(
                            height: 40,
                            width: size.width*0.45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: const Color(0xffFE00A8),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text('Confirm Purchase', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> CoinPlayerInfo(playerUrl))),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 25,),
                  ),
                )
              ],
            ),
          )
        );
      }
    );
  }
}