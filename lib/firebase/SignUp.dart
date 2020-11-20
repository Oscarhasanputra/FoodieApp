import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthSignUp{
    static final _googleSignin=GoogleSignIn();
    static final _db=Firestore.instance;
    
    static Future<GoogleSignInAccount> signUpWithGoogle() async{
      final _accountGoogle=await _googleSignin.signIn();
      print("is signed in : ${_googleSignin.isSignedIn()}");
      return _accountGoogle;
      // _db.collection("users").document(_accountGoogle.id).setData(
      //   {

      //   }
      // )
    }
}