import 'package:FoodieApp/bloc/historybloc.dart';
import 'package:FoodieApp/firebase/History.dart';
import 'package:FoodieApp/stream/controllerindicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'ConfirmationPage.dart';
import 'Loading.dart';
import 'bloc/cartlistitem.dart';
import 'firebase/Users.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (context) => HistoryBloc(),
            child: CenterController(key: GlobalKey(), child: CartBody())));
  }
}

class CartBody extends StatefulWidget {
  double nominal = 0;
  double total = 5000;
  double constanta = 0;
  @override
  _CartBodyState createState() => _CartBodyState();
}

class _CartBodyState extends State<CartBody> {
  var maxTotal = 0.0;
  @override
  initState() {
    super.initState();
    User.getUser().then((user) {
      setState(() {
        maxTotal = user.saldo;
      });
    });
    // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
    //     print("after build");
    // });
    // User _user= await User.getUser();
    // maxTotal=_user.saldo;
    final cartList = BlocProvider.of<CartListCubit>(context).cart;

    widget.total = cartList.getTotalHarga();
    // nominal=0;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print("total sama dengan $maxTotal");
    // print(" width :${min(size.width, size.height)}");
    return Container(
      child: Column(
        children: [
          Container(
            width: min(size.width, size.height) / 1.2,
            height: min(size.width, size.height) / 1.2,
            child: CartPayment(
                nominal: widget.nominal,
                total: widget.total,
                constanta: widget.constanta,
                maxTotal: maxTotal,
                onPayment: () {
                  final _parentWidget = context
                      .dependOnInheritedWidgetOfExactType<CenterController>();
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Are You Sure to pay this transaction?",
                                      style: GoogleFonts.roboto(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(true);

                                      // start animating to clear childtransaction
                                      // animasi pembayaran
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      height: 50,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.blue),
                                      child: Text("Yes",
                                          style: GoogleFonts.nunitoSans(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      height: 50,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.red),
                                      child: Text("No",
                                          style: GoogleFonts.nunitoSans(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).then((value) {
                    if (value) {
                      final gradient = widget.total / maxTotal;
                      final selisihInterval = -(widget.total / maxTotal);
                      final calculatedGradient = selisihInterval / gradient;
                      final absSelisih = (1 - calculatedGradient.abs());
                      setState(() {
                        widget.nominal = -widget.total;
                        widget.total += widget.nominal;
                        widget.constanta = calculatedGradient;
                      });
                      final _loading = Loading.of(context)..showLoading();

                      _parentWidget.controller.forward(
                          from: absSelisih); //start animation to decrease saldo

                      _parentWidget.streamIndicator
                        ..stream.listen((event) {
                          print("listening event");
                          print(event);
                          if (event == "finish") {
                            _loading.closeLoading();
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, _, __) =>
                                    ConfirmationScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) {
                                  var start = Tween<Offset>(
                                          begin: Offset(0, 1), end: Offset.zero)
                                      .animate(anim);
                                  return SlideTransition(
                                    position: start,
                                    child: child,
                                  );
                                }));
                          }
                        })
                        ..controller.add("starting");
                    }
                  });
                }),
          ),
          Text(
            "Cart Transaction",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color(0xff525490)),
          ),
          CartTransaction(onAdd: (nominal, cartItem) {
            if (widget.total + nominal <= maxTotal &&
                widget.total + nominal >= 0) {
              final gradient = widget.total / maxTotal;
              final selisihInterval = nominal / maxTotal;
              final calculatedGradient = selisihInterval / gradient;
              final absSelisih = (1 - calculatedGradient.abs());

              setState(() {
                widget.nominal = nominal;
                widget.total += nominal;
                widget.constanta = calculatedGradient;
              });
              context
                  .dependOnInheritedWidgetOfExactType<CenterController>()
                  .controller
                  .forward(from: absSelisih);
            } else {
              if (nominal < 0)
                cartItem.addItem(-1);
              else
                cartItem.addItem(1);
            }
          })
        ],
      ),
    );
  }
}
// class CartBody extends StatelessWidget {
//   @override
//   }

class CenterController extends InheritedWidget {
  AnimationController controller;
  final ControllerStreamIndicator streamIndicator = ControllerStreamIndicator();
  AnimationController controllerCart;
  final GlobalKey key;
  CenterController({this.key, Widget child}) : super(child: child, key: key);
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}

class CartTransaction extends StatefulWidget {
  final Function(double, CartItem) onAdd;
  CartTransaction({this.onAdd});
  @override
  _CartTransactionState createState() => _CartTransactionState();
}

class _CartTransactionState extends State<CartTransaction>
    with SingleTickerProviderStateMixin {
  AnimationController _controllerCart;
  int _totalDuration = 4000;
  bool start = false;
  // final _keyTest=UniqueKey();
  @override
  initState() {
    _controllerCart = AnimationController(
      duration: Duration(milliseconds: _totalDuration),
      vsync: this,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // context
    //     .dependOnInheritedWidgetOfExactType<CenterController>()
    //     .controllerCart = _controllerCart;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cartList = BlocProvider.of<CartListCubit>(context).cart;
    final cartFilterList =
        cartList.cart.values.where((element) => element.total > 0);
    return Expanded(
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: cartFilterList.map<Widget>((e) {
                return ChildTransaction(
                  key: Key(e.id),
                  onAdd: widget.onAdd,
                  item: e,
                  start: start,
                  itemCounts: cartFilterList.length,
                  index: cartFilterList.toList().indexOf(e),
                  onDestroy: () {
                    print("on Destroy");
                    setState(() {
                      final cartItem = cartFilterList.first;
                      User.getUser().then((user) {
                        final uuid = Uuid().v1();
                        History.getHistoryCollection(user.id).collection.set({
                          "$uuid": {
                            "type": "payment",
                            "cart": FieldValue.arrayUnion([
                              {
                                "type": "produk",
                                ...cartItem.toJson(),
                              }
                            ])
                          }
                        }, SetOptions(merge: true));
                      });
                      cartList.removeAt(cartItem.id);
                      if (cartFilterList.length == 0) {
                        cartList.saveCartList().then((data) {});
                        context
                            .dependOnInheritedWidgetOfExactType<
                                CenterController>()
                            .streamIndicator
                            .controller
                            .add("finish");
                      }
                    });
                  },
                );
              }).toList(),
            ),
          )),
    );
  }
}

class ChildTransaction extends StatefulWidget {
  final bool start;
  final CartItem item;
  final index, itemCounts;
  final Function(double, CartItem) onAdd;
  final Function() onDestroy;
  final Key key;
  ChildTransaction(
      {this.key,
      this.itemCounts,
      this.start,
      this.index,
      this.item,
      this.onAdd,
      this.onDestroy})
      : super(key: key);
  @override
  _ChildTransactionState createState() => _ChildTransactionState();
}

class _ChildTransactionState extends State<ChildTransaction>
    with SingleTickerProviderStateMixin {
  Animation<double> _eachAnimation;
  AnimationController _eachController;
  @override
  initState() {
    // final _totalDuration = 4000;
    // final _start = (_totalDuration / widget.itemCounts * widget.index)/_totalDuration;
    _eachController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..addStatusListener((status) {
            if (status.index == 3) {
              widget.onDestroy();
              // print("hello");
              // _eachController.dispose();
            }
          });

    print("widget is : ${widget.index}");
    // if (this.mounted) _eachController.forward();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    context
        .dependOnInheritedWidgetOfExactType<CenterController>()
        .streamIndicator
        .stream
        .asBroadcastStream()
        .listen((event) {
      if (event == "starting") {
        print("animating widget : ${widget.index}");
        Future.delayed(
                Duration(seconds: widget.index == 0 ? 0 : widget.index + 1))
            .then((value) {
          if (this.mounted) _eachController.forward();
        });
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eachController.view,
      builder: (context, child) {
        return Transform.translate(
            offset: Offset(
                _eachController.value == 0
                    ? 0
                    : (widget.index * 130) + 1000 * _eachController.value,
                0),
            child: Opacity(
              opacity: 1 - _eachController.value,
              child: child,
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
            Image.network(
              widget.item.image,
              width: 100,
              height: 100,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 20),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "${widget.item.nama}",
                  style: GoogleFonts.oswald(
                    fontSize: 30,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${widget.item.harga}",
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              widget.item.addItem(1);
                              widget.onAdd(widget.item.harga, widget.item);
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFffc003),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.add,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              widget.item.addItem(-1);
                              widget.onAdd(-widget.item.harga, widget.item);
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.remove,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text("Item : ${widget.item.total}")
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class CartProgres extends CustomPainter {
  final double progres;
  CartProgres(this.progres);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = new SweepGradient(
      startAngle: 3 * pi / 2,
      endAngle: 7 * pi / 2,
      tileMode: TileMode.repeated,
      colors: [Colors.blue, Colors.red],
    );

    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.butt // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - (8 / 2);
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progres;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return true;
  }
}

class CartPayment extends StatefulWidget {
  double total = 5000;
  final nominal;
  final maxTotal;
  final constanta;
  final Function() onPayment;
  CartPayment(
      {this.maxTotal,
      this.total,
      this.constanta,
      this.nominal,
      this.onPayment});
  @override
  _CartPaymentState createState() => _CartPaymentState();
}

class _CartPaymentState extends State<CartPayment>
    with SingleTickerProviderStateMixin {
  var _controller;
  initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void didChangeDependencies() {
    context.dependOnInheritedWidgetOfExactType<CenterController>().controller =
        _controller;

    _controller.forward();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final rate = (widget.total - widget.nominal) / widget.maxTotal;

    final size = MediaQuery.of(context).size;
    final minSize = min(size.width / 2.3, size.height / 2.3);
    // print("calculated ${rate *((1+1-widget.constanta.abs())-_controller.value)}");
    return FractionallySizedBox(
        widthFactor: 0.6,
        heightFactor: 0.6,
        child: Container(
          alignment: Alignment.center,
          child: Stack(alignment: Alignment.center, children: [
            FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Container(
                  child: CustomPaint(
                painter: CartProgres(rate *
                    (widget.constanta < 0
                        ? ((1 + 1 - widget.constanta.abs()) - _controller.value)
                        : widget.constanta + _controller.value)),
              )),
            ),
            Container(
              height: minSize,
              width: minSize,
              child: InkWell(
                onTap: () {
                  widget.onPayment();
                  // showModalBottomSheet(context: context, builder: (context)=>
                  //   FractionallySizedBox(
                  //     heightFactor: 0.3,
                  //     widthFactor: 1,
                  //     child: Container(
                  //       color: Colors.black,
                  //     ),
                  //   )
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 20,
                            offset: Offset(2, 2),
                            color: Colors.black38)
                      ]),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Payment",
                        style: GoogleFonts.roboto(
                            fontSize: 20, color: Color(0xffB7B7CD)),
                      ),
                      Text(
                        "\$${((widget.total) * _controller.value).toStringAsFixed(0)}",
                        style: GoogleFonts.notoSerif(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Color(0xff2B2C78)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
