import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isSensitiveKey(String key) {
    return key.toLowerCase().contains('token') || key.toLowerCase().contains('password');
  }

  Future<void> write(String key, String value) async {
    if (_isSensitiveKey(key)) {
      await _secureStorage.write(key: key, value: value);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<String?> read(String key) async {
    if (_isSensitiveKey(key)) {
      String? secureValue = await _secureStorage.read(key: key);
      if (secureValue == null) {
        // Auto-migration
        final prefs = await SharedPreferences.getInstance();
        final oldValue = prefs.getString(key);
        if (oldValue != null) {
          await _secureStorage.write(key: key, value: oldValue);
          await prefs.remove(key);
          return oldValue;
        }
      }
      return secureValue;
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> delete(String key) async {
    if (_isSensitiveKey(key)) {
      await _secureStorage.delete(key: key);
      // Fallback delete to ensure no leftover
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }

  Future<void> clear() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
