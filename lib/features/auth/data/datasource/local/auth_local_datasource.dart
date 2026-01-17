import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/services/hive/hive_service.dart';
import 'package:nepabite/core/services/storage/user_session_service.dart';
import 'package:nepabite/features/auth/data/datasource/auth_datasource.dart';
import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';

// Local datasource Provider
final authLocalDatasourceProvider = Provider<IAuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // Retrieve the current user from Hive
      return await _hiveService.getCurrentUser('authId');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      final exists = await _hiveService.isEmailExists(email);
      return exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      // Save user data in session using UserSessionService
      if (user != null) {
        await _userSessionService.saveUserSession(
          authId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          address: user.address,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      await _userSessionService.clearUserSession();  // Clear user session
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    return await _hiveService.registerUser(model);
  }
}
