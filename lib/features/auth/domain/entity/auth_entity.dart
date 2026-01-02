import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String? phoneNumber;
  final String? address;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    this.address,
    this.phoneNumber
  });

  @override
  List<Object?> get props => [authId, fullName, email, password, phoneNumber, address];
}