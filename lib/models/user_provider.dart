// path: lib/models/user_provider.dart

import 'package:flutter/material.dart';
import 'user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel.defaultUser();

  UserModel get user => _user;

  void updateUser({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    if (phone != null) _user.phone = phone;
    if (address != null) _user.address = address;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _user.notificationsEnabled = value;
    notifyListeners();
  }
}
