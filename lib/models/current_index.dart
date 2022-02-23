import 'package:flutter/material.dart';

class CurrentIndex with ChangeNotifier {
  int _index = 0;
  int get current_index => _index;

  void setIndex(value) {
    _index = value;
    notifyListeners();
  }
}
