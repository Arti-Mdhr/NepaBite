import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:nepabite/core/constants/hive_table_constant.dart';
import 'package:nepabite/features/auth/data/model/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';


// Hive Service Provider
final hiveServiceProvider= Provider((ref){
  return HiveService();
});

class HiveService {
  Future <void>init() async{
    final directory= await getApplicationDocumentsDirectory();

    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }
  
  // Register Adapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }
  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }
  // Close Boxes
  Future<void> close() async{
    await Hive.close();
  }

  // Makina a box for user things.
Box<AuthHiveModel> get _userBox => Hive. box(HiveTableConstant.authTable);

// register user
Future <AuthHiveModel> registerUser(AuthHiveModel model)async{
  await _userBox.put(model.authId, model);
  return model;
}

// User Login
Future<AuthHiveModel?> loginUser(String email, String password) async{

  final users= _userBox.values.where(
    (user)=>user.email == email && user.password==password,
  );
  if (users.isNotEmpty) {
    return users.first;
  }
  return null;
}

// user logout
Future<void>logout() async{

}

// Get Current User.
AuthHiveModel? getCurrentUser(String userId){
  return _userBox.get(userId);
}

bool isEmailExists(String email) {
  final users= _userBox.values.where((user)=>user.email == email);
  return users.isNotEmpty;
}
}



