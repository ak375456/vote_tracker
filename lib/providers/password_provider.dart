import 'package:flutter/material.dart';

class ShowPassword with ChangeNotifier {
  bool isObsecureText = false;
  void showPassword(show) {
    isObsecureText = show;
    notifyListeners();
  }
}
