import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk menangani autentikasi biometrik dan penyimpanan kredensial
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Keys untuk secure storage
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Cek apakah device mendukung biometrik
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Cek apakah biometrik tersedia (sidik jari/wajah terdaftar)
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Dapatkan daftar biometrik yang tersedia
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Autentikasi menggunakan biometrik
  static Future<bool> authenticate({
    String localizedReason =
        'Sentuh sensor sidik jari untuk masuk ke ShopeZone',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      final canCheck = await canCheckBiometrics();

      if (!isSupported || !canCheck) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Simpan kredensial ke secure storage
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  /// Dapatkan kredensial tersimpan
  static Future<Map<String, String?>> getSavedCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    return {
      'email': email,
      'password': password,
    };
  }

  /// Cek apakah ada kredensial tersimpan
  static Future<bool> hasCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    return email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty;
  }

  /// Hapus kredensial tersimpan
  static Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
  }

  /// Aktifkan biometric login
  static Future<void> enableBiometric() async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Nonaktifkan biometric login
  static Future<void> disableBiometric() async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  /// Cek apakah biometric login diaktifkan
  static Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Cek apakah biometric login tersedia dan diaktifkan
  static Future<bool> canUseBiometricLogin() async {
    final hasCredential = await hasCredentials();
    final isEnabled = await isBiometricEnabled();
    final canCheck = await canCheckBiometrics();
    return hasCredential && isEnabled && canCheck;
  }

  /// Dapatkan nama biometrik yang tersedia (untuk UI)
  static Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Sidik Jari';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometrik';
  }
}
