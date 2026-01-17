import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    this.address,
    this.phoneNumber
  });

  @override
  List<Object?> get props => [authId, fullName, email, password,confirmPassword, phoneNumber, address];
}