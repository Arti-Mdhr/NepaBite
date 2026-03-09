import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:nepabite/features/auth/domain/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/usecases/upload_profile_image_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late UploadProfileImageUsecase uploadProfileImageUsecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    uploadProfileImageUsecase = UploadProfileImageUsecase(
      authRepository: mockAuthRepository,
    );
  });

  final fakeImage = File('test_image.jpg');

  final updatedEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@gmail.com',
    image: '/uploads/users/test_image.jpg',
  );

  test(
    'should return updated AuthEntity when image upload is successful',
    () async {
      // arrange
      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Right(updatedEntity));

      // act
      final result = await uploadProfileImageUsecase(fakeImage);

      // assert
      expect(result, Right(updatedEntity));
      verify(() => mockAuthRepository.uploadProfileImage(any())).called(1);
    },
  );

  test(
    'should return Failure when image upload fails',
    () async {
      // arrange
      final failure = ApiFailure(message: 'Failed to upload image');

      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await uploadProfileImageUsecase(fakeImage);

      // assert
      expect(result, Left(failure));
      verify(() => mockAuthRepository.uploadProfileImage(any())).called(1);
    },
  );

  test(
    'should return AuthEntity with a non-empty image path after upload',
    () async {
      // arrange
      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Right(updatedEntity));

      // act
      final result = await uploadProfileImageUsecase(fakeImage);

      // assert
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (entity) => expect(entity.image, isNotEmpty),
      );
    },
  );

  test(
    'should pass a File object to the repository',
    () async {
      // arrange
      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Right(updatedEntity));

      // act
      await uploadProfileImageUsecase(fakeImage);

      // assert
      final captured = verify(
        () => mockAuthRepository.uploadProfileImage(captureAny()),
      ).captured;
      expect(captured.first, isA<File>());
    },
  );

  test(
    'should not interact with repository more than once per call',
    () async {
      // arrange
      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Right(updatedEntity));

      // act
      await uploadProfileImageUsecase(fakeImage);

      // assert
      verify(() => mockAuthRepository.uploadProfileImage(any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return correct failure message when server rejects the image',
    () async {
      // arrange
      final failure = ApiFailure(message: 'File type not supported');

      when(() => mockAuthRepository.uploadProfileImage(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await uploadProfileImageUsecase(fakeImage);

      // assert
      result.fold(
        (f) => expect(f.message, 'File type not supported'),
        (_) => fail('Expected failure but got success'),
      );
    },
  );
}