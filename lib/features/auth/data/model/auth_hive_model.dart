import 'package:hive/hive.dart';
import 'package:nepabite/core/constants/hive_table_constant.dart';
import 'package:nepabite/features/auth/domain/entity/auth_entity.dart';
import 'package:uuid/uuid.dart';


part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String? phoneNumber;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.password,
    this.address,
    this.phoneNumber,
  }):authId=authId ?? Uuid().v4();

  AuthEntity toEntity() {
    return AuthEntity(authId: authId, fullName: fullName, email: email,password: password,address: address,phoneNumber: phoneNumber);
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity){
    return AuthHiveModel(fullName: entity.fullName, email: entity.email, password: entity.password);
  }

  static List<AuthEntity>toEntityList(List<AuthHiveModel> model){
    return model.map((model)=>model.toEntity()).toList();
  }
}
