import 'package:equatable/equatable.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';

enum AuthStatus { initial,loading, authenticated, unauthenticated,registered, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status=AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? userEntity,
    String? errorMessage
  }){
    return AuthState(
      status: status ?? this.status,
      authEntity: userEntity ?? authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}