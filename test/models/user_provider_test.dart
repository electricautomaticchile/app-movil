import 'package:electricautomaticchile/models/user_model.dart';
import 'package:electricautomaticchile/models/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores and clears enterprise permissions', () {
    final provider = UserProvider();

    provider.setUser(
      UserModel(nombre: 'Empresa', correo: 'admin@empresa.cl'),
      permissions: {'clientes.ver': true, 'usuarios.editar': false},
    );

    expect(provider.can('clientes.ver'), isTrue);
    expect(provider.can('usuarios.editar'), isFalse);
    expect(provider.permissions.length, 2);

    provider.clearUser();

    expect(provider.user, isNull);
    expect(provider.permissions, isEmpty);
  });
}
