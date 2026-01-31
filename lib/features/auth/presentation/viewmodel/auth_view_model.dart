import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepabite/features/auth/domain/usecases/register_usecase.dart';
import 'package:nepabite/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:nepabite/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider =
    NotifierProvider<UserViewModel, AuthState>(() => UserViewModel());

class UserViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final UploadProfileImageUsecase _uploadProfileImageUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _uploadProfileImageUsecase =
        ref.read(uploadProfileImageUsecaseProvider);
    return const AuthState();
  }
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? address,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final registerParams = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      phoneNumber: phoneNumber,
    );

    final result = await _registerUsecase.call(registerParams);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: "Registration failed",
          );
        }
      },
    );
  }
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final loginParams =
        LoginUsecaseParams(email: email, password: password);

    final result = await _loginUsecase(loginParams);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (userEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: userEntity,
        );
      },
    );
  }
  Future<void> uploadProfileImage(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadProfileImageUsecase.call(image);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (userEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: userEntity,
        );
      },
    );
  }
}
