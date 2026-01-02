import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/data/datasource/auth_datasource.dart';
import 'package:nepabite/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';


final authRepositoryProvider= Provider<IAuthRepository>((ref){
  final authDatasource= ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDataSource: authDatasource);
});


class AuthRepository implements IAuthRepository{
  final IAuthDatasource _authDatasource;

  AuthRepository({ required IAuthDatasource authDataSource}): _authDatasource=authDataSource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async{
    try {
      final user= await _authDatasource.getCurrentUser();
      if (user != null) {
        final userEntity= user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Couldnot get current user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password) async {
    try {
      final user= await _authDatasource.loginUser(email, password);
      if (user != null) {
        final userEntity= user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Failed to Log In User"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Cannot Log User Out"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity entity) async{
    try {
      // Here We convert the incoming entity into model.
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.registerUser(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to Register User"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

}