import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDataService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveCredentials(String username, String password) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final username = await _secureStorage.read(key: 'username');
    final password = await _secureStorage.read(key: 'password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _secureStorage.deleteAll();
  }
}
