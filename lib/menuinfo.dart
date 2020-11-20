import 'dart:convert';
import 'dart:math';

import 'package:FoodieApp/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:FoodieApp/factory/factorylist.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/cartlistitem.dart';
import 'firebase/Users.dart';

class MenuDetailPage extends StatelessWidget {
  final Recipe recipe;

  MenuDetailPage({this.recipe});
  @override
  Widget build(BuildContext context) {
    return MenuInfoScreen(recipe: this.recipe);
  }
}

class MenuInfoScreen extends StatelessWidget {
  final Recipe recipe;
  RecipeInformationList _informationList;
  MenuInfoScreen({this.recipe});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  child: Hero(
                    tag: "${recipe.id}",
                    child: Image.network(
                      "${recipe.imageFood}",
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              ),
              Flexible(
                  flex: 4,
                  child: Container(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  textScreen(
                                      title: "Price",
                                      info: "${recipe.price}",
                                      icon: Icon(
                                        FontAwesome5.money_bill_alt,
                                        color: Colors.green,
                                      )),
                                  textScreen(
                                      title: "Health",
                                      info: "${recipe.health}",
                                      icon: Icon(FontAwesome.heartbeat,
                                          color: Colors.pink)),
                                  textScreen(
                                      title: "Likes",
                                      info: "${recipe.like}",
                                      icon: Icon(Icons.thumb_up_alt,
                                          color: Colors.blue)),
                                ]),
                            SizedBox(height: 20),
                            AddMenu(recipe: recipe),
                            SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "${recipe.food}",
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 0, top: 10, bottom: 100),
                                        child: Html(
                                          data: "${recipe.summary}",
                                          style: {
                                            "body": Style(
                                                textAlign: TextAlign.center,
                                                alignment: Alignment.center,
                                                fontSize: FontSize.large)
                                          },
                                          onLinkTap: (url) async {
                                            if (await canLaunch(url))
                                              await launch(url);
                                          },
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return DraggableScrollableSheet(
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return RecipeContainer(
                                            _informationList, scrollController);
                                      },
                                    );
                                  },
                                );
                              },
                              child: FutureBuilder(
                                  future: ApiRequest.getReq(
                                      "${recipe.id}/information?"),
                                  builder: (context,
                                      AsyncSnapshot<Response> response) {
                                    if (response.hasData) {
                                      final informationList =
                                          RecipeInformationList.fromJson(
                                              jsonDecode(response.data.body));
                                      // print("data informasi : ${informationList.list}");
                                      _informationList = informationList;
                                      return Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15))),
                                        child: Center(
                                          child: Icon(FontAwesome.reorder,
                                              size: 30, color: Colors.white),
                                        ),
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  })),
                        )
                      ],
                    ),
                  )),
            ],
          )),
    );
  }

  Widget textScreen({title, info, Icon icon}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        Text("$info",
            style: GoogleFonts.openSans(fontSize: 15, color: Colors.black))
      ],
    );
  }
}

class AddMenu extends StatefulWidget {
  final Recipe recipe;
  AddMenu({this.recipe});
  @override
  _AddMenuState createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
  @override
  Widget build(BuildContext context) {
    final cartList = BlocProvider.of<CartListCubit>(context);
    final total = (cartList.cart.cart["${widget.recipe.id}"]?.total ?? 0);
    final totalHarga = total * widget.recipe.price;
    print("rebuild");
    // print
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xffFE71B3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "\$ ${totalHarga.toStringAsFixed(2)}",
                style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Text(
            "$total",
            style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      print("clicked");

                      // cartList.cart.cart["${widget.recipe.id}"]?.addItem(1);

                      final _user = await User.getUser();
                      if (cartList.cart.getTotalHarga() + widget.recipe.price >
                          _user.saldo) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Saldo Tidak Mencukupi, \nSilahkan Top Up terlebih dahulu"),
                        ));
                      } else {
                        cartList.cart.addItem(CartItem(
                            id: "${widget.recipe.id}",
                            image: widget.recipe.imageFood,
                            nama: widget.recipe.food,
                            harga: widget.recipe.price,
                            total: 1));
                        setState(() {});
                      }
                    },
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        final cartItem =
                            cartList.cart.cart["${widget.recipe.id}"];
                        cartItem.total - 1 < 0
                            ? cartItem.total = 0
                            : cartItem?.addItem(-1);
                      });
                    },
                    child: Icon(
                      Icons.remove,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RecipeContainer extends StatelessWidget {
  final RecipeInformationList recipe;
  final ScrollController _controller;
  RecipeContainer(this.recipe, this._controller);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Icon(FontAwesome.reorder, size: 30, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            "Recipe",
            style: GoogleFonts.roboto(fontSize: 30, color: Colors.white),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 30),
            child: ListView(
              children: recipe?.list
                  .map<Widget>((rec) => ingredientWidget(
                      name: rec.name,
                      image: rec.image,
                      step: rec.step,
                      colorbg: rec.colorbg))
                  .toList(),
            ),
          ),
        ),
      ]),
    );
  }

  Widget ingredientWidget({image, name, step, Color colorbg}) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, right: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
          color: colorbg,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Image.network(
            "https://spoonacular.com/cdn/ingredients_100x100/$image",
            width: 100,
            height: 100,
            fit: BoxFit.fill,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 100,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$name",
                      style: GoogleFonts.oswald(fontSize: 30),
                    ),
                    Container(
                      child: Text("$step",
                          style: GoogleFonts.quicksand(
                              fontSize: 20, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
