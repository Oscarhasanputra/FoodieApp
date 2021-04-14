import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartListCubit extends Cubit<CartList> {
  // var cartlist=CartList();
  CartListCubit() : super(CartList());

  CartList get cart => state;
}

class CartList {
  Future<dynamic> initialize() async {
    final sharedStore = await SharedPreferences.getInstance();
    final Map<dynamic, dynamic> dataCartList =
        jsonDecode(sharedStore.getString("cartlist"));
    // this.cart = dataCartList;
    final keys = dataCartList.keys;
    keys.forEach((key) {
      final cartData = dataCartList[key];

      final cartItem = CartItem.mapToCartItem(cartData);

      this.cart[key] = cartItem;
    });
    // return dataCartList;
  }

  Map<String, CartItem> cart = {};
  Future<void> addItem(CartItem item) async {
    if (cart.containsKey(item.id))
      cart[item.id].addItem(item.total);
    else
      cart[item.id] = item;

    final sharedStore = await SharedPreferences.getInstance();
    final cartStringList = jsonEncode(cart);
    sharedStore.setString("cartlist", cartStringList);
  }

  void removeAt(String key) async {
    cart.remove(key);
  }

  void removeIndex(int index) {
    final key = cart.keys.elementAt(index);
    print("key is : $key");
    removeAt(key);
  }

  Future<Map<dynamic, CartItem>> saveCartList() async {
    final sharedStore = await SharedPreferences.getInstance();
    final cartStringList = jsonEncode(this.cart);
    sharedStore.setString("cartlist", cartStringList);
    return this.cart;
  }

  void removeAllCart() {
    this.cart = {};
  }

  int getTotalCart() {
    double total = 0;
    cart.values.forEach((e) {
      total += e.total;
    });
    return total.toInt();
  }

  double getTotalHarga() {
    double total = 0;
    cart.values.forEach((e) {
      total += e.getHargaTotalItem();
    });
    return total;
  }

  Map toJson() {
    var initCart = {};
    cart.keys.map((keyId) {
      initCart[keyId] = cart[keyId];
    });
    return initCart;
  }
}

class CartItem {
  final image, nama, harga, id;
  var total;
  CartItem({this.id, this.image, this.nama, this.harga, this.total});

  static CartItem mapToCartItem(Map<dynamic, dynamic> cart) {
    // print(ca)
    final total = cart['total'] ?? 0;
    return CartItem(
        image: cart['image'],
        id: cart['id'],
        nama: cart['nama'],
        total: total,
        harga: cart['harga']);
  }

  void addItem(int jumlah) async {
    if (total + jumlah >= 0) {
      total += jumlah;
      final sharedStore = await SharedPreferences.getInstance();
      final Map<dynamic, dynamic> dataCartList =
          jsonDecode(sharedStore.getString("cartlist"));
      dataCartList[this.id] = this.toJson();
      final dataCartListString = jsonEncode(dataCartList);
      sharedStore.setString("cartlist", dataCartListString);
      // sharedStore.setString("cartlist", cartStringList);
    }
  }

  double getHargaTotalItem() {
    return this.total * this.harga;
  }

  Map toJson() {
    return {
      "image": this.image,
      "nama": this.nama,
      "harga": this.harga,
      "id": this.id,
      "total": this.total
    };
  }
}
