import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;
  final String? image;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.address,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "phoneNumber": phoneNumber,
      "address": address,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;

    return AuthApiModel(
      id: userJson['_id'] as String?,
      fullName: userJson['fullName'] as String? ?? '',
      email: userJson['email'] as String? ?? '',
      password: userJson['password'] as String? ?? '',
      confirmPassword: userJson['confirmPassword'] as String?,
      phoneNumber: userJson['phoneNumber'] as String? ?? '',
      address: userJson['address'] as String? ?? '',
      image: userJson['image'] as String?,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      phoneNumber: phoneNumber,
      image: image, 
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      image: entity.image,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
