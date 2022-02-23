import 'package:flutter/material.dart';

class SelectedValue with ChangeNotifier {
  String _selected_value = 'Online';
  String get current_selected_value => _selected_value;

  void setSelectedValue(String value) {
    _selected_value = value;
    notifyListeners();
  }
}
