import 'dart:math';

import 'package:FoodieApp/api.dart';
import 'package:flutter/material.dart';

class RecipeList{
  final List<Recipe> list;
  bool isContainList=false;
  bool isChange=false;
  RecipeList({this.list}){
    if(this.list!=null){
        this.isContainList=true;
    }
  }
  factory RecipeList.fromJson(Map<String, dynamic> json){
    return RecipeList(
      list: json['results'].map<Recipe>((e){
        return Recipe(e);
      }).toList()
    );
  }
}

class Recipe{
  var like,health,price,id,food,imageFood,summary,order=0;
  Recipe(Map<String,dynamic> json){
    like=json['aggregateLikes'];
    health= json['healthScore'];
    price=json['pricePerServing'];
    id=json['id'];
    food=json['title'];
    imageFood=json['image'];
    summary=json['summary'];
  }
  set addOrder(int jumlahOrder)=>order+jumlahOrder<0?0:order+jumlahOrder;
}

class RecipeInformationList {
  final list;
  RecipeInformationList({this.list});
  factory RecipeInformationList.fromJson(Map<String, dynamic> json){
    return RecipeInformationList(
      list: json['extendedIngredients'].map((e){
        return RecipeInformation(e);
      }).toList()
    );
  }
}

class RecipeInformation{
  var image,name,id,step,colorbg;
  RecipeInformation(Map<String,dynamic> json){
      image=json['image'];
      name=json['name'];
      id=json['id'];
      step=json['original'];
      colorbg=Color(Random().nextInt(0xffffffff)).withAlpha(0xff);
  }
}