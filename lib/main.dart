
import 'package:FoodieApp/SignUpPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import "menu.dart";

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(LoginScreen());
}

