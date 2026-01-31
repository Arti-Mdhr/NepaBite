
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/usecases/login_usecase.dart';


class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase loginUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  const email = 'test@gmail.com';
  const password = 'password123';

  final authEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: email,
  );

  test(
    'should return AuthEntity when login is successful',
    () async {
      // arrange
      when(() => mockAuthRepository.loginUser(email, password))
          .thenAnswer((_) async => Right(authEntity));

      // act
      final result = await loginUsecase(
        const LoginUsecaseParams(
          email: email,
          password: password,
        ),
      );

      // assert
      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.loginUser(email, password)).called(1);
    },
  );

  test(
    'should return Failure when login fails',
    () async {
      // arrange
      final failure = ApiFailure(message: 'Invalid credentials');

      when(() => mockAuthRepository.loginUser(email, password))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await loginUsecase(
        const LoginUsecaseParams(
          email: email,
          password: password,
        ),
      );

      // assert
      expect(result, Left(failure));
      verify(() => mockAuthRepository.loginUser(email, password)).called(1);
    },
  );
}
