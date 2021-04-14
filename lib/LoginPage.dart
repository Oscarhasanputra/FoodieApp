import 'package:FoodieApp/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "menu.dart";
import 'Loading.dart';
import 'firebase/Users.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(backgroundColor: Colors.blue, body: LoginPage()),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey;
  bool isShowPassword = false;
  final _formValue = {};
  initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 50),
      padding: EdgeInsets.only(left: 30, top: 30),
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black)],
          color: Colors.white,
          borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(30), topStart: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome",
              style: GoogleFonts.roboto(
                  fontSize: 40, fontWeight: FontWeight.bold)),
          Text(
            "Back!",
            style:
                GoogleFonts.roboto(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraint) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 30),
                              child: TextFormField(
                                validator: (input) {
                                  bool validEmail = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(input);
                                  print("is valid : $validEmail");
                                  if (!validEmail)
                                    return "Masukan Email dengan benar";
                                  _formValue["email"] = input;
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    hintText: "Masukan Email Anda",
                                    labelText: "Email"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 30, top: 30, bottom: 40),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      obscureText: !isShowPassword,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          hintText: "Masukan Password",
                                          labelText: "Password",
                                          suffixIcon: IconButton(
                                            icon: isShowPassword
                                                ? Icon(Icons.remove_red_eye,
                                                    color: Colors.blue,
                                                    size: 30)
                                                : Icon(
                                                    Icons
                                                        .remove_red_eye_outlined,
                                                    color: Colors.blue,
                                                    size: 30),
                                            onPressed: () {
                                              setState(() {
                                                isShowPassword =
                                                    !isShowPassword;
                                              });
                                            },
                                          )),
                                      validator: (pw) {
                                        if (pw.isEmpty)
                                          return "Password tidak boleh kosong";
                                        _formValue["password"] = pw;
                                        return null;
                                      },
                                      onFieldSubmitted: (_) {
                                        submitLogin();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sign In",
                            style: GoogleFonts.oswald(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RaisedButton(
                            onPressed: submitLogin,
                            padding: EdgeInsets.all(20),
                            color: Color(0xffFF7F56),
                            shape: CircleBorder(),
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 40),
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SignUpScreen()));
                              },
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.roboto(
                                  decoration: TextDecoration.underline,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Text("Forgot Password",
                                style: GoogleFonts.roboto(
                                  decoration: TextDecoration.underline,
                                  fontSize: 18,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitLogin() async {
    if (_formKey.currentState.validate()) {
      final _loading = Loading.of(context)..showLoading();
      User.getUserLogin(_formValue['email'], _formValue['password'])
          .then((snapshot) {
        final _data = snapshot.docs.first.data();
        User.saveUser(
            id: snapshot.docs.first.id,
            saldo: _data['saldo'],
            email: _data['email'],
            nama: _data['nama'],
            photo: _data['photo'],
            password: _data['password']);
        _loading.closeLoading();
        if (snapshot.size > 0) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
                pageBuilder: (context, _, __) => MenuScreen(),
                transitionsBuilder: (context, animation, secondAnim, child) {
                  var begin = Offset(1, 0.0);
                  var end = Offset.zero;
                  var tween = Tween(begin: begin, end: end);
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                      position: offsetAnimation, child: child);
                }),
          );
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Email atau Password salah, Silahkan Coba Lagi!"),
          ));
        }
      }).catchError((error) {
        _loading.closeLoading();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Email atau Password salah, Silahkan Coba Lagi!"),
        ));
      });
    }
    // User.getUserLogin(form, password)
  }
}
