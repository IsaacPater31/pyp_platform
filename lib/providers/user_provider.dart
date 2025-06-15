import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _role;
  int? _userId;

  String? get username => _username;
  String? get role => _role;
  int? get userId => _userId;

  void login(String username, String role, [int? userId]) {
    _username = username;
    _role = role;
    _userId = userId;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _role = null;
    _userId = null;
    notifyListeners();
  }
}
