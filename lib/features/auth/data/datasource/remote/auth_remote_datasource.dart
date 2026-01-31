import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/core/services/storage/user_session_service.dart';
import 'package:nepabite/features/auth/data/datasource/auth_datasource.dart';
import 'package:nepabite/features/auth/data/model/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getCurrentUser() {
    throw UnimplementedError();
  }

   @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userLogin,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String?;
        final data = response.data['user'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(data);
        if (token != null && token.isNotEmpty) {
          await _userSessionService.saveAuthToken(token);
        }

        await _userSessionService.saveUserSession(
          authId: user.id!,
          email: user.email,
          fullName: user.fullName,
        );

        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthApiModel?> uploadProfileImage(File image) async {
    try {
      final fileName = path.basename(image.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadProfileImage,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.data['success'] == true) {
        final data = response.data['user'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(data);

        await _userSessionService.saveUserSession(
          authId: user.id!,
          email: user.email,
          fullName: user.fullName,
        );

        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userRegister,
        data: model.toJson(),
      );
      if (response.data['success'] == true) {
        final data = response.data['user'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(data);
      }
      return model;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}
