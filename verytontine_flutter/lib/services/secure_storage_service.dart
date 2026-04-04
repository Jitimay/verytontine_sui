import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeEphemeralKey(String key) async {
    await _storage.write(key: 'ephemeral_key', value: key);
  }
  
  static Future<String?> getEphemeralKey() async {
    return await _storage.read(key: 'ephemeral_key');
  }
  
  static Future<void> storeAuthData(String address, String token) async {
    await _storage.write(key: 'sui_address', value: address);
    await _storage.write(key: 'id_token', value: token);
  }
  
  static Future<Map<String, String?>> getAuthData() async {
    return {
      'address': await _storage.read(key: 'sui_address'),
      'token': await _storage.read(key: 'id_token'),
    };
  }
  
  /// Stores a generic key-value pair
  static Future<void> storeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  /// Retrieves a value by key
  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }
  
  /// Deletes a specific key
  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
  
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
