import 'package:cricverse/coin_player_info.dart';
import 'package:cricverse/providers/coins_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;
class CoinsScreen extends StatefulWidget {
  const CoinsScreen({Key? key}) : super(key: key);

  @override
  State<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {

  double roundToDecimalPlaces(double number, int decimalPlaces) {
    double multiplier = Math.pow(10, decimalPlaces).toDouble();
    return (number * multiplier).round() / multiplier;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1)).then((value){
      final provider = Provider.of<CoinsProvider>(context, listen: false);
      provider.getCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<CoinsProvider>(
      builder: (context, coinProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: coinProvider.inProgress? const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(color: Color(0xffFE00A8),),
            ): const Center(),
            centerTitle: true,
            title: Text('Available Coins', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600),),
          ),
          body: coinProvider.coinSnapshot!=null? ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              ...coinProvider.coinSnapshot!.entries.map((e){
                Map<Object?, Object?> coinInfo = e.value as Map<Object?, Object?>;
                String coinValue = '${roundToDecimalPlaces(double.tryParse(coinInfo['initial_value'].toString())!, 2)}';
                return ListTile(
                  onTap: (){
                    coinProvider.confirmationDialog(context, coinValue, e.key.toString(), size, coinInfo['href'].toString());
                  },
                  title: Text(e.key.toString(), style: GoogleFonts.poppins(color: Colors.white70)),
                  subtitle: Text('Current Value: $coinValue',
                  style: GoogleFonts.poppins(color: Colors.white70)),
                  trailing: IconButton(
                    onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> CoinPlayerInfo(coinInfo['href'].toString()))),
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.white70,),
                  ),
                );
              })
            ],
          ) : const Center(
            child: CircularProgressIndicator(color: Color(0xffFE00A8),),
          ),
        );
      },
    );
  }
}
