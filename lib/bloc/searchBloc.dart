import 'dart:async';
import 'dart:convert';

import 'package:FoodieApp/factory/factorylist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FoodieApp/api.dart';

class SearchUrlCubit extends Cubit<RecipeList> {

  static final number = 10;
  static final baseURL =
      "complexSearch?addRecipeInformation=true&number=$number";
  static final url =
      "complexSearch?query=&addRecipeInformation=true&number=10&apiKey=${ApiRequest.apiKey}&offset=0";
  int _offset = 0;
  String _query="";
  bool _isChange=false;
  static RecipeList _list=RecipeList();
  SearchUrlCubit() : super(_list);

  void getInitializedData() async {
    final _response = await ApiRequest.getReq("$baseURL&query=");

    final _recipeList = RecipeList.fromJson(jsonDecode(_response.body));
    
    // AsyncSnapshot.withData(ConnectionState.done, _recipeList);
    emit(_recipeList);
  }

  Future<RecipeList> _getData() async {
    final _response =
        await ApiRequest.getReq("$baseURL&query=${this._query}&offset=${this._offset}");

    final _recipeList = RecipeList.fromJson(jsonDecode(_response.body));
    return _recipeList;
  }

  void nextPage() async {
    
    this._offset = (_offset + 1) * number;
    
    print("hello this is me");
    final _data=await _getData();
    // await _data;
    emit(_data);
    
  }

  void changeQuery({query}) async{
    this._query=query;
    this._offset=0;
    _list.isChange=true;
    emit(_list);
    final _data=await _getData();
    emit(_data);
  }
}
