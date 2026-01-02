import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';

abstract interface class IAuthDatasource {
  Future<bool>registerUser(AuthHiveModel model);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool>logout();

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exixts
  Future<bool> isEmailExists(String email);
}