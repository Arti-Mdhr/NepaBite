import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  final authEntity = AuthEntity(
    fullName: 'Test User',
    email: 'test@gmail.com',
    password: 'password123',
    confirmPassword: 'password123',
    phoneNumber: '9800000000',
    address: 'Kathmandu',
  );

  test(
    'should return true when registration is successful',
    () async {
      // arrange
      when(() => mockAuthRepository.registerUser(authEntity))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await registerUsecase(
        RegisterUsecaseParams(
          fullName: authEntity.fullName,
          email: authEntity.email,
          password: authEntity.password!,
          confirmPassword: authEntity.confirmPassword!,
          phoneNumber: authEntity.phoneNumber,
          address: authEntity.address,
        ),
      );

      // assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.registerUser(authEntity)).called(1);
    },
  );

  test(
    'should return Failure when registration fails',
    () async {
      // arrange
      final failure = ApiFailure(message: 'Registration failed');

      when(() => mockAuthRepository.registerUser(authEntity))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await registerUsecase(
        RegisterUsecaseParams(
          fullName: authEntity.fullName,
          email: authEntity.email,
          password: authEntity.password!,
          confirmPassword: authEntity.confirmPassword!,
          phoneNumber: authEntity.phoneNumber,
          address: authEntity.address,
        ),
      );

      // assert
      expect(result, Left(failure));
      verify(() => mockAuthRepository.registerUser(authEntity)).called(1);
    },
  );
}
