import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> registerUser(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  
  Future<Either<Failure, AuthEntity>> uploadProfileImage(File image);
}