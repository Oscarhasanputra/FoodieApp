import 'dart:io';

import 'package:FoodieApp/firebase/SignUp.dart';
import 'package:camera/camera.dart';
import 'package:camera/new/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'menu.dart';

import 'Loading.dart';
import 'LoginPage.dart';
import 'camera/Camera.dart';
import 'firebase/Users.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SignUpPage());
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var filePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text("Sign Up Your Data!",
                  style: GoogleFonts.firaMono(
                      fontSize: 30, fontWeight: FontWeight.bold))),
          Center(
              child: Image(
                  image: Image.asset(
            "images/signup.png",
            color: Colors.transparent,
          ).image)),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 40),
              decoration: BoxDecoration(
                  color: Color(0xffE6EDF3),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TakePictureCamera(
                      onfilePath: (filePath) {
                        setState(() {
                          this.filePath = filePath;
                        });
                      },
                    ),
                    FormSignUp(
                      filePath: this.filePath,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FormSignUp extends StatefulWidget {
  final String filePath;
  FormSignUp({this.filePath});
  @override
  _FormSignUpState createState() => _FormSignUpState();
}

class _FormSignUpState extends State<FormSignUp> {
  var _formKey;
  final Map<String, dynamic> _formValue = {};

  @override
  initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 40),
            child: TextFormField(
              validator: (input) {
                if (input.isEmpty) return "Nama Tidak boleh Kosong";
                _formValue["nama"] = input;
                return null;
              },
              decoration: InputDecoration(
                  hintText: "Masukan Nama Anda", labelText: "Nama"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40),
            child: TextFormField(
              validator: (input) {
                bool validEmail = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(input);
                print("is valid : $validEmail");
                if (!validEmail) return "Masukan Email dengan benar";
                _formValue["email"] = input;
                return null;
              },
              decoration: InputDecoration(
                  hintText: "Masukan Email", labelText: "Email"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40),
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Masukan Password", labelText: "Password"),
              validator: (pw) {
                if (pw.isEmpty) return "Password tidak boleh kosong";
                _formValue["password"] = pw;
                return null;
              },
            ),
          ),
          SizedBox(height: 5),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Sign Up With",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    RaisedButton(
                      color: Colors.transparent,
                      onPressed: () {
                        print("hello");
                        AuthSignUp.signUpWithGoogle().then((account) {
                          print("nama user ${account.displayName}");
                          // final formModal=;
                          User.getUserLoginById(account.id)
                              .then((docSnap) async {
                                // print("id : ${account.id}");
                            final _data = docSnap.data();
                            if (_data != null) {
                              final _loading = Loading.of(context)
                                ..showLoading();
                              await User.saveUser(
                                  id:account.id,
                                  email: _data['email'],
                                  password: _data['password'],
                                  photo: _data['photo'],
                                  nama: _data['nama'],
                                  saldo: _data['saldo']);
                              _loading.closeLoading();
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text("Berhasil Login"),
                                  ))
                                  .closed
                                  .then((reason) {
                                Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
                                    pageBuilder: (context, _, __) =>
                                        MenuScreen(),
                                    transitionsBuilder:
                                        (context, animation, second, child) {
                                      var begin = Offset(1, 0.0);
                                      var end = Offset.zero;
                                      var tween = Tween(begin: begin, end: end);
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                          position: offsetAnimation,
                                          child: child);
                                    }),(Route<dynamic> route)=>route is SignUpScreen);
                              });
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40))),
                                  builder: (context) {
                                    return PasswordFormGoogle(account);
                                  }).then((value) {
                                Scaffold.of(context)
                                    .showSnackBar(SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text("Data Berhasil Disimpan"),
                                    ))
                                    .closed
                                    .then((reason) {
                                  Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (context, _, __) =>
                                          LoginScreen(),
                                      transitionsBuilder:
                                          (context, animation, second, child) {
                                        var begin = Offset(1, 0.0);
                                        var end = Offset.zero;
                                        var tween =
                                            Tween(begin: begin, end: end);
                                        var offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                            position: offsetAnimation,
                                            child: child);
                                      }));
                                });
                              });
                            }
                          });
                        });
                      },
                      shape: CircleBorder(),
                      child: Image.asset(
                        "images/google.png",
                        width: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if (widget.filePath == null) {
                            // _formValue['photo']=widget.filePath;
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Photo tidak boleh Kosong!")));
                          } else {
                            FirebaseStorage storage = FirebaseStorage.instance;

                            // print(widget.filePath);
                            final _fileName = widget.filePath.split("/");

                            final _loading = Loading.of(context)..showLoading();
                            Reference ref = storage.ref().child(
                                "photo/${_fileName[_fileName.length - 1]}");
                            UploadTask task =
                                ref.putFile(File(widget.filePath));
                            // ref.putData();
                            task.whenComplete(() {
                              print("hola");
                              ref.getDownloadURL().then((url) {
                                // print("$url");
                                _formValue['photo'] = url;
                                _formValue['saldo']=0;
                                final _uuId = Uuid();
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc("${_uuId.v1()}")
                                    .set(_formValue)
                                    .then((_) {
                                  // Navigator.of(context).pop();
                                  _loading.closeLoading();
                                  Scaffold.of(context)
                                      .showSnackBar(SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Data Berhasil Disimpan"),
                                      ))
                                      .closed
                                      .then((reason) {
                                    Navigator.of(context).push(PageRouteBuilder(
                                        pageBuilder: (context, _, __) =>
                                            LoginScreen(),
                                        transitionsBuilder: (context, animation,
                                            second, child) {
                                          var begin = Offset(1, 0.0);
                                          var end = Offset.zero;
                                          var tween =
                                              Tween(begin: begin, end: end);
                                          var offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                              position: offsetAnimation,
                                              child: child);
                                        }));
                                  });
                                });
                              });
                            });
                            // task.then((snap) {
                            //     snap.
                            // });

                            // final _bottomSheetController=Scaffold.of(context).showBottomSheet((context) => CircularProgressIndicator());

                          }
                        }
                      },
                      padding: EdgeInsets.all(20),
                      color: Color(0xffFF7F56),
                      shape: CircleBorder(
                          side: BorderSide(
                        color: Color(0xffFF7F56),
                      )),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PasswordFormGoogle extends StatefulWidget {
  final GoogleSignInAccount account;
  PasswordFormGoogle(this.account);
  @override
  _PasswordFormGoogleState createState() => _PasswordFormGoogleState();
}

class _PasswordFormGoogleState extends State<PasswordFormGoogle> {
  bool isNotVisible = true;
  TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Enter Your Password!",
                  style: GoogleFonts.nunitoSans(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: isNotVisible,
                        controller: _password,
                        decoration: InputDecoration(
                            hintText: "Masukan Password",
                            labelText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 1,
                                ))),
                      ),
                    ),
                    IconButton(
                      icon: isNotVisible
                          ? Icon(Icons.remove_red_eye,
                              size: 30, color: Colors.blue)
                          : Icon(Icons.remove_red_eye_outlined,
                              color: Colors.blue, size: 30),
                      onPressed: () {
                        setState(() {
                          isNotVisible = !isNotVisible;
                        });
                      },
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.save,
                          size: 30,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          final _loading = Loading.of(context)..showLoading();

                          await User.addUserGoogleSignin(
                              account: widget.account,
                              password: _password.text);
                          _loading.closeLoading();
                          Navigator.of(context).pop(); //close modal formModal
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TakePictureCamera extends StatefulWidget {
  final Function(String) onfilePath;
  TakePictureCamera({this.onfilePath});
  @override
  _TakePictureCameraState createState() => _TakePictureCameraState();
}

class _TakePictureCameraState extends State<TakePictureCamera> {
  String filePath;
  @override
  Widget build(BuildContext context) {
    // print("rebuild");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: displayPic(),
        ),
        SizedBox(width: 20),
        Flexible(
          flex: 2,
          child: InkWell(
            onTap: () async {
              final camera = await availableCameras();
              final filePathString = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return CameraScreen(camera: camera);
              }));
              // setState(() {
              filePath = filePathString;
              widget.onfilePath(filePath);
              // });
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  "Take a Picture",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget displayPic() {
    final imageContainer = filePath != null
        ? Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: Image.file(
                  File(filePath),
                  fit: BoxFit.fill,
                  width: 100,
                ).image)))
        : Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(100)),
            child: Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 50,
              ),
            ),
          );
    return imageContainer;
  }
}
