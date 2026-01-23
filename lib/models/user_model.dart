// path: lib/models/user_model.dart

class UserModel {
  String name;
  String email;
  String phone;
  String address;
  bool notificationsEnabled;

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.notificationsEnabled = true,
  });

  // Mock default user
  static UserModel defaultUser() {
    return UserModel(
      name: 'Emmanuel García',
      email: 'emmanuel@correo.com',
      phone: '+56 9 1234 5678',
      address: 'Av. Principal 123, Santiago',
      notificationsEnabled: true,
    );
  }
}
