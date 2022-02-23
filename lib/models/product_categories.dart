import 'package:flutter/material.dart';

class ProductCategories with ChangeNotifier {
  List _productCategories = [];
  List get product_categories => _productCategories;

  void setProductCategories(List value) {
    _productCategories = value;
    notifyListeners();
  }
}
