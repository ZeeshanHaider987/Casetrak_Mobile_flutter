import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT and tenant id live in secure storage. Keys are shared by mock and remote.
abstract class TokenStore {
  static const tokenKey = 'auth_token';
  static const tenantKey = 'tenant_id';
  static const userKey = 'login_user';

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clearSession();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clearSession() async {
    await delete(TokenStore.tokenKey);
    await delete(TokenStore.tenantKey);
    await delete(TokenStore.userKey);
  }
}

class MemoryTokenStore implements TokenStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clearSession() async => _values.clear();
}
