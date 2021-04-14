import 'dart:convert';

import 'package:FoodieApp/bloc/cartlistitem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryBloc extends Cubit<Map<dynamic, CartItem>> {
  HistoryBloc() : super({});

  Future<void> initialize() async {
    final sharedStore = await SharedPreferences.getInstance();
    final Map history = jsonDecode(sharedStore.getString("history"));
    final mapInit = {};
    history.keys.forEach((key) {
      final data = history[key];

      mapInit[key] = CartItem.mapToCartItem(data);
    });
    emit(mapInit);

    // setDataHistory(mapInit);
  }

  void setDataHistory(Map<dynamic, CartItem> data) {
    data.keys.forEach((key) {
      final cartItem = data[key];
      if (state.containsKey(key)) {
        state[key].total += cartItem.total;
      } else
        state[key] = data[key];
    });
    emit(state);
  }

  void save() async {
    final sharedStore = await SharedPreferences.getInstance();
    final historyString = jsonEncode(state);
    print("history");
    print(historyString);
    sharedStore.setString("history", historyString);
  }
}
