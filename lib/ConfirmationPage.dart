import 'package:FoodieApp/bloc/historybloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: BlocProvider(
            create: (context) => HistoryBloc(), child: ConfirmationPage()));
  }
}

class ConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blocHistory = BlocProvider.of<HistoryBloc>(context);
    blocHistory.initialize();
    return Container(
      color: Color(0xff55BFB5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FontAwesome.check_circle_o,
              color: Colors.white, size: MediaQuery.of(context).size.width / 2),
          Container(
            child: Text(
              "Payment Success",
              style: GoogleFonts.roboto(fontSize: 50, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
