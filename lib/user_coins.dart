import 'package:cricverse/providers/coins_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;

class UserCoins extends StatefulWidget {
  const UserCoins({Key? key}) : super(key: key);

  @override
  State<UserCoins> createState() => _UserCoinsState();
}

class _UserCoinsState extends State<UserCoins> {


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
      provider.fetchPurchasedCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoinsProvider>(
      builder: (context, coinProvider, child){
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Your Purchase', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),),
          ),
          body: coinProvider.purchasedCoins.isNotEmpty? ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38),
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payout will start soon.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),),
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.ankh, color: Colors.white70, size: 10,),
                        Text(': Value you received after investing in a coin.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),)
                      ],
                    ),
                  ],
                ),
              ),
              ...coinProvider.purchasedCoins.entries.map((e){
                Map<Object?, Object?> coinInfoMap = e.value as Map<Object?, Object?>;
                Object msSinceEpoch = e.key??'';
                final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(msSinceEpoch.toString()));
                String formattedDate = DateFormat('dd-MM-y, hh:mm a').format(dateTime);
                return ListTile(
                  leading: const Icon(FontAwesomeIcons.coins, color: Colors.white70,),
                  title: Text(coinInfoMap['coin_name'].toString(), style: GoogleFonts.poppins(color: Colors.white70),),
                  subtitle: Row(
                    children: [
                      const Icon(FontAwesomeIcons.ankh, color: Colors.white70, size: 12,),
                      Text(coinInfoMap['percentage_owned'].toString(), style: GoogleFonts.poppins(color: Colors.white70),),
                      Text('   •   ', style: GoogleFonts.poppins(color: Colors.white70)),
                      Text(formattedDate, style: GoogleFonts.poppins(color: Colors.white70),),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: ()=> coinProvider.updateCoinsValueMap(coinInfoMap['coin_name'].toString(), e.key.toString()),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        coinProvider.coinsValueMap[e.key.toString()]!=null
                            ? Text('Worth: ₹${roundToDecimalPlaces((double.parse(coinProvider.coinsValueMap[e.key.toString()]!)*double.parse(coinInfoMap['purchased_value'].toString())/100), 2)}',
                                style: GoogleFonts.poppins(color: Colors.white70),)
                            : const Icon(FontAwesomeIcons.eye, color: Colors.white70, size: 16,)
                      ],
                    ),
                  )
                );
              }),
            ]
          )
              : const Center(
            child: CircularProgressIndicator(color: Color(0xffFE00A8),),
          ),
        );
      },
    );
  }
}
