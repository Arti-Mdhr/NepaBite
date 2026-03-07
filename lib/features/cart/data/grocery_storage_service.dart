import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entity/grocery_list_entity.dart';

class GroceryStorageService {

  static const key = "grocery_lists";

  Future<void> saveList(GroceryListEntity list) async {

    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(key);

    List data = [];

    if (existing != null) {
      data = jsonDecode(existing);
    }

    data.add(list.toJson());

    await prefs.setString(key, jsonEncode(data));
  }

  Future<List<GroceryListEntity>> getLists() async {

    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) return [];

    final decoded = jsonDecode(data);

    return decoded
        .map<GroceryListEntity>((e) => GroceryListEntity.fromJson(e))
        .toList();
  }
}