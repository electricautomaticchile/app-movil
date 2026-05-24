import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyBiometricRut = 'biometric_rut';

  /// Check if device supports biometrics
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Check if user has enabled biometric login
  static Future<bool> isEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  /// Enable biometric session unlock without storing the user's password.
  static Future<void> enable(String rut) async {
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
    await _storage.write(key: _keyBiometricRut, value: rut);
  }

  /// Remove saved credentials
  static Future<void> disable() async {
    await _storage.delete(key: _keyBiometricEnabled);
    await _storage.delete(key: _keyBiometricRut);
  }

  /// Authenticate with biometrics and return the remembered RUT.
  static Future<String?> authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Usa tu huella o Face ID para iniciar sesión',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!authenticated) return null;

      final rut = await _storage.read(key: _keyBiometricRut);

      if (rut == null) return null;
      return rut;
    } on PlatformException {
      return null;
    }
  }
}
