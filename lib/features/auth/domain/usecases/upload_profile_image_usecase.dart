import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/data/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';

final uploadProfileImageUsecaseProvider =
    Provider<UploadProfileImageUsecase>((ref) {
  return UploadProfileImageUsecase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class UploadProfileImageUsecase {
  final IAuthRepository _authRepository;

  UploadProfileImageUsecase({
    required IAuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<Either<Failure, AuthEntity>> call(File image) async {
    return await _authRepository.uploadProfileImage(image);
  }
}
