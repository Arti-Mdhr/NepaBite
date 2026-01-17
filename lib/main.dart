import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/app/app.dart';  // Import your app's main widget
import 'package:nepabite/core/services/hive/hive_service.dart';  // Import any services if necessary
import 'package:shared_preferences/shared_preferences.dart';

// Define the FutureProvider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive service (if needed)
  await HiveService().init();

  // Run the app within ProviderScope
  runApp(ProviderScope(child: MyApp()));  // Make sure your app is wrapped in ProviderScope
}
