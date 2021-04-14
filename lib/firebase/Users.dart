import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final id, photo, password, email, nama;
  double saldo;
  final _fireStore = FirebaseFirestore.instance;
  User({this.id, this.photo, this.password, this.email, this.nama, this.saldo});

  Map toJson() {
    return {
      "id": this.id,
      "photo": this.photo,
      "password": this.password,
      "email": this.email,
      "nama": this.nama,
      "saldo": this.saldo,
    };
  }

  Stream<DocumentSnapshot> getSaldoStream() {
    // print("id user : ${this.id}");
    return _fireStore.collection("users").doc(this.id).snapshots();
  }

  static Future<void> addUser(Map<String, dynamic> data) async {
    final uuid = Uuid();
    return FirebaseFirestore.instance
        .collection("users")
        .doc("${uuid.v1()}")
        .set(data);
  }

  static Future<void> addUserGoogleSignin(
      {GoogleSignInAccount account, password}) async {
    final uuid = Uuid();
    return FirebaseFirestore.instance
        .collection("users")
        .doc("${account.id}")
        .set({
      "saldo": 0.0,
      "photo": "${account.photoUrl}",
      "password": "$password",
      "email": "${account.email}",
      "nama": "${account.displayName}"
    });
  }

  static Future<QuerySnapshot> getUserLogin(String email, String password) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();
  }

  static Future<DocumentSnapshot> getUserLoginById(String id) {
    return FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  static Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map user = jsonDecode(prefs.getString("user"));
    print("id user : ${user['saldo']}");
    if (user != null) return User.mapToUser(user);

    throw ("User Belum Login");
  }

  factory User.mapToUser(Map<String, dynamic> user) {
    // if(user!=null)
    return User(
        id: user['id'],
        email: user['email'],
        nama: user['nama'],
        password: user['password'],
        photo: user['photo'],
        saldo: user['saldo']);
  }
  static Future<bool> saveUser(
      {id, email, password, nama, photo, saldo}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    User user = User(
        id: id,
        email: email,
        password: password,
        nama: nama,
        photo: photo,
        saldo: saldo);
    String _user = jsonEncode(user);
    return prefs.setString("user", _user);
  }

  Future<void> setSaldo(double saldo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(this.saldo);
    this.saldo += saldo;
    String _user = jsonEncode(this);
    prefs.setString("user", _user);
  }
}
