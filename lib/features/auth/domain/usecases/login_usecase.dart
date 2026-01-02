import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/core/usecases/app_usecase.dart';
import 'package:nepabite/features/auth/data/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;
  const LoginUsecaseParams({
    required this.email,
    required this.password
  });

  @override
  List<Object?> get props =>[email, password];

}

// Provder For Login Usecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref){
  return LoginUsecase(authRepository: ref.read(authRepositoryProvider));
});



class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams>{
  final IAuthRepository _authRepository;
  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;


  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.loginUser(params.email, params.password);
  }
  
}