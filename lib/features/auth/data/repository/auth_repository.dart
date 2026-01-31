import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/core/services/connectivity/network_info.dart';
import 'package:nepabite/features/auth/data/datasource/auth_datasource.dart';
import 'package:nepabite/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:nepabite/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:nepabite/features/auth/data/model/auth_api_model.dart';
import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final localDatasource = ref.read(authLocalDatasourceProvider);
  final remoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    localDataSource: localDatasource,
    remoteDataSource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _localDataSource;
  final IAuthRemoteDatasource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource localDataSource,
    required IAuthRemoteDatasource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _remoteDataSource.loginUser(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Invalid Credentials'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _localDataSource.loginUser(email, password);
        if (user != null) {
          return Right(user.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Failed to log in'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        await _remoteDataSource.registerUser(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(entity);
        await _localDataSource.registerUser(model);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCurrentUser();
      if (user != null) {
        final authEntity = user.toEntity();
        return Right(authEntity);
      }
      return Left(LocalDatabaseFailure(message: 'Could not get current user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _localDataSource.logout();
      if (result) {
        await _remoteDataSource.logout();
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Cannot log user out'));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Logout Failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> uploadProfileImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _remoteDataSource.uploadProfileImage(image);
        if (apiModel != null) {
          final entity = apiModel.toEntity();

          // Attempt to update local cache (best-effort)
          try {
            final model = AuthHiveModel.fromEntity(entity);
            await _localDataSource.registerUser(model);
          } catch (_) {}

          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Profile upload failed'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Profile upload failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}