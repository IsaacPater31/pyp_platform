import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _role;

  String? get username => _username;
  String? get role => _role;

  void login(String username, String role) {
    _username = username;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _role = null;
    notifyListeners();
  }
}
