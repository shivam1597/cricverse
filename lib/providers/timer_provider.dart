import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
class TimerProvider extends ChangeNotifier{

  int secondsUsed = 0;
  Timer? timer;

  Future<void> startTimer() async {
    final box = await Hive.openBox('myBox');
    if(box.get('timeSpent') != null){
      secondsUsed = box.get('timeSpent');
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsUsed++;
      if(secondsUsed%5==0){
        notifyListeners();
      }
      box.put('timeSpent', secondsUsed);
    });
  }
  
  void fetchSeconds()async{
    final box = await Hive.openBox('myBox');
    if(box.get('timeSpent') != null){
      secondsUsed = box.get('timeSpent');
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsUsed++;
      box.put('timeSpent', secondsUsed);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}