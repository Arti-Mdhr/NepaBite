import 'package:nepabite/features/auth/data/model/auth_api_model.dart';
import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<AuthHiveModel> registerUser(AuthHiveModel model);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exists
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> registerUser(AuthApiModel model);
  Future<AuthApiModel?> getCurrentUser();
  Future<AuthApiModel?> loginUser(String email, String password);
  Future<bool> logout();
}