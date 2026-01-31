import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/core/services/connectivity/network_info.dart';
import 'package:nepabite/features/auth/data/datasource/auth_datasource.dart';

import 'package:nepabite/features/auth/data/model/auth_api_model.dart';
import 'package:nepabite/features/auth/data/repository/auth_repository.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';

class MockRemoteDatasource extends Mock implements IAuthRemoteDatasource {}
class MockLocalDatasource extends Mock implements IAuthLocalDatasource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepository repository;
  late MockRemoteDatasource mockRemoteDatasource;
  late MockLocalDatasource mockLocalDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();
    mockLocalDatasource = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepository(
      remoteDataSource: mockRemoteDatasource,
      localDataSource: mockLocalDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  const email = 'test@gmail.com';
  const password = 'password123';

  final apiModel = AuthApiModel(
    id: '1',
    fullName: 'Test User',
    email: email,
    password: password,
  );

  test(
    'should return AuthEntity when network is connected and remote login succeeds',
    () async {
      // arrange
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);

      when(() => mockRemoteDatasource.loginUser(email, password))
          .thenAnswer((_) async => apiModel);

      // act
      final result = await repository.loginUser(email, password);

      // assert
      expect(result, isA<Right<Failure, AuthEntity>>());
      verify(() => mockRemoteDatasource.loginUser(email, password)).called(1);
      verifyNever(() => mockLocalDatasource.loginUser(any(), any()));
    },
  );
}
