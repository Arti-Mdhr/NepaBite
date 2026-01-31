import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});

class UserSessionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Error saving auth token: $e');
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Error reading auth token: $e');
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Error clearing auth token: $e');
    }
  }

  Future<void> saveUserSession({
    required String authId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authId', authId);
      await prefs.setString('email', email);
      await prefs.setString('fullName', fullName);
      await prefs.setString('phoneNumber', phoneNumber ?? '');
      await prefs.setString('address', address ?? '');

      await _secureStorage.write(key: 'authId', value: authId);
    } catch (e) {
      throw Exception('Error saving session data: $e');
    }
  }

  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authId');
      await prefs.remove('email');
      await prefs.remove('fullName');
      await prefs.remove('phoneNumber');
      await prefs.remove('address');

      await _secureStorage.delete(key: 'authId');
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Error clearing session data: $e');
    }
  }

  Future<Map<String, String>?> getUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('authId');
      final email = prefs.getString('email');
      final fullName = prefs.getString('fullName');
      final phoneNumber = prefs.getString('phoneNumber');
      final address = prefs.getString('address');

      if (authId != null && email != null && fullName != null) {
        return {
          'authId': authId,
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber ?? '',
          'address': address ?? '',
        };
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving session data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('authId');
      return authId != null;
    } catch (e) {
      throw Exception('Error checking login status: $e');
    }
  }
}
