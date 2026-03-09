import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepabite/features/auth/domain/usecases/register_usecase.dart';
import 'package:nepabite/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:nepabite/features/auth/presentation/state/auth_state.dart';
import 'package:nepabite/features/auth/presentation/viewmodel/auth_view_model.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockUploadProfileImageUsecase extends Mock implements UploadProfileImageUsecase {}
class FakeFile extends Fake implements File {}
class FakeLoginParams extends Fake implements LoginUsecaseParams {}
class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

void main() {
  late ProviderContainer container;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadProfileImageUsecase mockUploadUsecase;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  final authEntity = AuthEntity(
    authId: '1',
    fullName: 'Arti Shrestha',
    email: 'arti@gmail.com',
  );

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadUsecase = MockUploadProfileImageUsecase();

    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        uploadProfileImageUsecaseProvider
            .overrideWithValue(mockUploadUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'initial state should be AuthStatus.initial with no user or error',
    () {
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'login should set status to authenticated and store user on success',
    () async {
      // arrange
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Right(authEntity));

      // act
      await container.read(authViewModelProvider.notifier).login(
            email: 'arti@gmail.com',
            password: 'password123',
          );

      // assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity?.fullName, 'Arti Shrestha');
    },
  );

  test(
    'login should set status to error with message when credentials are wrong',
    () async {
      // arrange
      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Invalid credentials')),
      );

      // act
      await container.read(authViewModelProvider.notifier).login(
            email: 'arti@gmail.com',
            password: 'wrongpassword',
          );

      // assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
      expect(state.authEntity, isNull);
    },
  );

  test(
    'register should set status to registered on success',
    () async {
      // arrange
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      await container.read(authViewModelProvider.notifier).register(
            fullName: 'Arti Shrestha',
            email: 'arti@gmail.com',
            password: 'password123',
            confirmPassword: 'password123',
            phoneNumber: '9800000000',
            address: 'Kathmandu',
          );

      // assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.registered);
    },
  );

  test(
    'logout should reset state back to initial',
    () async {
      // arrange — login first so state is authenticated
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Right(authEntity));

      await container.read(authViewModelProvider.notifier).login(
            email: 'arti@gmail.com',
            password: 'password123',
          );

      // act
      container.read(authViewModelProvider.notifier).logout();

      // assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
    },
  );
}