import 'dart:convert';
import 'package:FoodieApp/Loading.dart';
import 'package:FoodieApp/firebase/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'Cart.dart';
import 'package:FoodieApp/bloc/cartlistitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'bloc/searchBloc.dart';
import 'menuinfo.dart';
import 'api.dart';
import 'package:FoodieApp/factory/factorylist.dart';

class MenuScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartListCubit(),
      child: MaterialApp(
        title: 'Flutter Demo',
        color: Colors.white,
        home: Scaffold(
          body: Container(
            padding: EdgeInsets.only(top: 40),
            color: Color(0xffDDE1F5),
            child: Column(
              children: [
                Flexible(
                  flex: 0,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Color(0xffEEECF6),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 20),
                        ]),
                    child: IntrinsicHeight(
                      child: FutureBuilder(
                        future: User.getUser(),
                        builder: (context, AsyncSnapshot<User> dataUser) {
                          if (dataUser.hasData) {
                            final _user = dataUser.data;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(flex: 2, child: ProfilInfo(_user)),
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: Image.network(
                                                    "${_user.photo}",
                                                    height: 100,
                                                    width: 100,
                                                  ).image),
                                            )),
                                      ),
                                      TopUp(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
                MenuListContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaldoInfo extends StatelessWidget {
  final User _user;
  SaldoInfo(this._user);
  @override
  Widget build(BuildContext context) {
    // print("build saldo");
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(20),
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)],
          color: Color(0xffc5d0fc),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(FontAwesome5.money_bill_alt, size: 30, color: Colors.green),
            StreamBuilder(
              stream: _user.getSaldoStream(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> document) {
                final _saldo = document.hasData
                    ? document.data.get("saldo").toString()
                    : 0;
                return Text(
                  "\$ $_saldo",
                  style: GoogleFonts.merriweather(
                      fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ProfilInfo extends StatelessWidget {
  // final user=User
  // final user=User.getUser();
  final User _user;
  ProfilInfo(this._user);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_user.nama}",
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Saldo",
              style: GoogleFonts.robotoCondensed(
                  fontSize: 23, fontWeight: FontWeight.w100),
            ),
          ),
          SaldoInfo(_user),
        ],
      ),
    );
  }
}

class MenuListContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          // border: Border.all(color: const Color(0xFF5ae6d6),width: 0.5),
          color: const Color(0xFF06c7b7),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: MenuList(),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("calling");
    return BlocProvider(
        create: (context) => SearchUrlCubit(), child: FormContainer());
  }
}

class FormContainer extends StatefulWidget {
  GlobalKey<_FormContainerState> key = GlobalKey();
  FormContainer({this.key}) : super(key: key);
  @override
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  var id;
  List<Recipe> _list;
  AnimationController _controller;

  ScrollController _scrollController;
  Animation<double> _animation;
  var _offsetPage = 0;
  @override
  initState() {
    _list = [];
    BlocProvider.of<SearchUrlCubit>(context).getInitializedData();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          // url="1";
          getMoreData();
        }
      });
    super.initState();
  }

  void getMoreData() {
    print("hello");
    final _searchCubit = BlocProvider.of<SearchUrlCubit>(context);
    _searchCubit.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      FormSearch(
        onInit: (_controllerForm) {
          _controller = _controllerForm;
        },
      ),
      BlocBuilder<SearchUrlCubit, RecipeList>(
        builder: (context, _recipeList) {
          print("yeahh");
          if (_recipeList.isChange)
            _list = [];
          else if (_recipeList.isContainList) {
            _list.addAll(_recipeList.list);
          }
          return Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index == _list.length)
                  return Center(
                      child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )));
                return Menu(
                  recipe: _list[index],
                  onController: () {
                    id = _list[index].id;
                    // jumlah += 1;
                    print(_controller);
                    _controller.forward();
                    // print("hello");
                  },
                );
              },
              controller: _scrollController,
              itemCount: _list.length + 1,
              scrollDirection: Axis.vertical,
            ),
          );
        },
      ),
    ]);
  }

  dispose() {
    super.dispose();
  }
}

class Menu extends StatelessWidget {
  final Recipe recipe;
  Function() onController;
  Menu({this.recipe, this.onController});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MenuDetailPage(
            recipe: recipe,
          ),
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end);
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black54,
          )
        ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Hero(
              tag: "${recipe.id}",
              child: Image.network(
                "${recipe.imageFood}",
                width: 100,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(width: 20),
            MenuInfo(
              recipe: recipe,
              onController: onController,
            ),
          ],
        ),
      ),
    );
  }
}

class TopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                final _controllerText = TextEditingController();
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Container(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top Up Saldo",
                            style: GoogleFonts.anton(
                              fontSize: 30,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextField(
                            controller: _controllerText,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Saldo",
                              hintText: "Masukan Saldo",
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () async {
                                
                                final _loading = Loading.of(context)..showLoading();
                                final _user = await User.getUser();
                                await _user.setSaldo(int.parse(_controllerText.text));
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(_user.id)
                                    .update({"saldo": _user.saldo});
                                
                                Navigator.of(context).pop();
                                _loading.closeLoading();
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ]),
                  ),
                );
              });
        },
        child: FractionallySizedBox(
          heightFactor: 1,
          widthFactor: 1,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Color(0xff56D0EB),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(1, 3),
                    color: Colors.black26,
                    blurRadius: 10,
                  )
                ]),
            child: Text(
              "Top Up",
              style: GoogleFonts.fjallaOne(
                  color: Colors.white, fontSize: 20, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuInfo extends StatelessWidget {
  final Recipe recipe;
  final Function() onController;
  MenuInfo({this.recipe, this.onController});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "${recipe.food}",
          style: GoogleFonts.oswald(
            fontSize: 30,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$ ${recipe.price}",
              style: GoogleFonts.roboto(
                fontSize: 20,
              ),
            ),
            InkWell(
              onTap: () async {
                final cubit = BlocProvider.of<CartListCubit>(context);
                // recipe.addOrder=1;
                final _user = await User.getUser();
                if (cubit.cart.getTotalHarga() + recipe.price > _user.saldo) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Saldo Tidak Mencukupi, \nSilahkan Top Up terlebih dahulu"),
                  ));
                } else {
                  cubit.cart.addItem(CartItem(
                      id: "${recipe.id}",
                      image: recipe.imageFood,
                      nama: recipe.food,
                      harga: recipe.price,
                      total: 1));

                  onController();
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFffc003),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20, color: Colors.white),
                            Text("ADD",
                                style: GoogleFonts.roboto(
                                    fontSize: 20, color: Colors.white))
                          ]),
                    ],
                  )),
            ),
          ],
        ),
      ],
    ));
  }
}

class FormSearch extends StatefulWidget {
  final Function(AnimationController) onInit;
  FormSearch({this.onInit});
  @override
  _FormSearchState createState() => _FormSearchState();
}

class _FormSearchState extends State<FormSearch>
    with SingleTickerProviderStateMixin {
  CartListCubit cubit;
  AnimationController _controllerForm;
  @override
  void initState() {
    // TODO: implement initState
    cubit = BlocProvider.of<CartListCubit>(context);
    _controllerForm =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this)
          ..addStatusListener((status) {
            if (status.index == 3) {
              _controllerForm.reverse();
            }
          });
    widget.onInit(_controllerForm);
    // print(GlobalKey<_FormContainerState>().currentState);
    // GlobalKey<_FormContainerState>().currentState._controller=_controllerForm;
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies

  //   super.didChangeDependencies();
  // }
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.5,
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(0xFF457cf5)),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.white,
                ),
                // Icon(Icons.search,size: 40,color: Colors.white,),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: "Search"),
                      onSubmitted: (string) {
                        BlocProvider.of<SearchUrlCubit>(context)
                            .changeQuery(query: string);
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => CartScreen()));
            },
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                      color: Color(0xFFff2003),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFff2003), blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                AnimatedBuilder(
                    animation: _controllerForm.view,
                    builder: (context, child) {
                      print("animated rebuild");
                      return Positioned(
                        right: -10,
                        child: Transform.scale(
                          scale: (1 + 0.2 * _controllerForm.value) ?? 1,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 20)
                                ],
                                borderRadius: BorderRadius.circular(50)),
                            child: Text(
                              "${cubit.cart.getTotalCart()}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// class FormSearch extends StatelessWidget {
//   final double controllerValue;
//   final jumlah;
//   FormSearch({this.controllerValue, this.jumlah});

// }
