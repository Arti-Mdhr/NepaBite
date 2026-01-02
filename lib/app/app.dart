import 'package:flutter/material.dart';
import 'package:nepabite/onboarding/splash_screen.dart';
import 'package:nepabite/app/themes/app_theme.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: applicationTheme(), 
      home: SplashScreen(), 
    );
  }
}
