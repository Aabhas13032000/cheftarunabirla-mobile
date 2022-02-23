import 'package:flutter/material.dart';

class CourseCategories with ChangeNotifier {
  List _courseCategories = [];
  List get course_categories => _courseCategories;

  void setCourseCategories(List value) {
    _courseCategories = value;
    notifyListeners();
  }
}
