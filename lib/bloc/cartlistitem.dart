import 'package:flutter_bloc/flutter_bloc.dart';

class CartListCubit extends Cubit<CartList>{
  // var cartlist=CartList();
  CartListCubit() : super(CartList());
  
  CartList get cart=>state;
}
class CartList {
  Map<String,CartItem> cart={};
  void addItem(CartItem item){
    if(cart.containsKey(item.id))
      cart[item.id].addItem(item.total);
    else cart[item.id]=item;
  }

  void removeAt(String key){
    cart.remove(key);
  }
  void removeIndex(int index){
    final key=cart.keys.elementAt(index);
    print("key is : $key");
    removeAt(key);
  }
  void removeAllCart(){
    this.cart={};
  }

  int getTotalCart(){
    double total=0;
    cart.values.forEach((e){total+=e.total;
    });
    return total.toInt();
  }

  double getTotalHarga(){
     double total=0;
    cart.values.forEach((e){total+=e.getHargaTotalItem();
    });
    return total;
  }
}
class CartItem{
  final image,nama,harga,id;
  var total;
  CartItem({this.id,this.image,this.nama,this.harga,this.total});

  void addItem(int jumlah){
    if(total+jumlah>=0){
    total+=jumlah;
    }
  }

  double getHargaTotalItem(){
      return this.total*this.harga;
  }
}