import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/core/usecases/app_usecase.dart';
import 'package:nepabite/features/auth/data/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String? address;
  final String? phoneNumber;
  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.password,
    this.address,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email, password, address, phoneNumber];
}

// Provider for register usecase.
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(authRepository: ref.read(authRepositoryProvider));
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      address: params.address,
      phoneNumber: params.phoneNumber,
    );
    return _authRepository.registerUser(authEntity);
  }
}
