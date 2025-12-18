import 'package:flutter/material.dart';

ThemeData getApplicatiomTheme(){
  return  ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "OpenSans Regular"
      );
}