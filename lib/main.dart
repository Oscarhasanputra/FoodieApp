import 'package:FoodieApp/SignUpPage.dart';
import 'package:FoodieApp/firebase/History.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import "menu.dart";
import "firebase/Users.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //listener update history topup;
  User.getUser().then((user) {
    History.getHistoryCollection(user.id)
        .collection
        .snapshots()
        .forEach((history) {
      final dataHist = history.data();
      dataHist.keys.where((key) {
        final historyData = dataHist["$key"];

        return historyData['type'] == "topup" &&
            historyData['status'] == "approve";
      }).forEach((key) {
        print("history list");

        final historyData = dataHist["$key"];
        final saldo = double.parse(historyData['saldo'].toString());
        user.setSaldo(saldo).then((_) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.id)
              .update({"saldo": user.saldo}).then((value) {
            historyData['status'] = "done";
            history.reference
                .set({"$key": historyData}, SetOptions(merge: true));
          });
        });
      });
    });
    runApp(MenuScreen());
  }).catchError((error) {
    runApp(LoginScreen());
  });
}
