import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/app/app.dart';
import 'package:nepabite/core/services/hive_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  runApp(ProviderScope(child: const MyApp()));
}
