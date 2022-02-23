import 'package:flutter/material.dart';

class CartItems with ChangeNotifier {
  List _cart = [];
  List get current_cart => _cart;

  void setCart(List value) {
    _cart = value;
    notifyListeners();
  }
}
