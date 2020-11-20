import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading {
  final BuildContext context;
  Loading(this.context);
  static Loading of(BuildContext context){
    context=context;
    return Loading(context);
  }

  void showLoading() {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, _a) => Material(
              // type: MaterialType.transparency,
              color: Colors.white.withOpacity(0.5),
              // make sure that the overlay content is not cut off
              child: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            )));
  }
  void closeLoading(){
      Navigator.of(context).pop();
  }
}
