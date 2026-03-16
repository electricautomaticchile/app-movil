import 'package:flutter/material.dart';
import 'user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // M-02: Limpieza segura de datos sensibles
  void clearUser() {
    if (_user != null) {
      _user!.nombre = '';
      _user!.correo = '';
      _user!.telefono = '';
      _user!.direccion = '';
      _user!.rut = '';
    }
    _user = null;
    notifyListeners();
  }

  void updateUser({
    String? nombre,
    String? correo,
    String? telefono,
    String? direccion,
    String? ciudad,
    String? rut,
    String? imagenPerfil,
  }) {
    if (_user == null) return;
    if (nombre != null) _user!.nombre = nombre;
    if (correo != null) _user!.correo = correo;
    if (telefono != null) _user!.telefono = telefono;
    if (direccion != null) _user!.direccion = direccion;
    if (ciudad != null) _user!.ciudad = ciudad;
    if (rut != null) _user!.rut = rut;
    if (imagenPerfil != null) _user!.imagenPerfil = imagenPerfil;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    if (_user == null) return;
    _user!.notificacionesSms = value;
    notifyListeners();
  }
}
