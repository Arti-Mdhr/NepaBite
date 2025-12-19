import 'package:flutter/material.dart';

class SavedRecipeScreen extends StatefulWidget {
  const SavedRecipeScreen({super.key});

  @override
  State<SavedRecipeScreen> createState() => _SavedRecipeScreenState();
}

class _SavedRecipeScreenState extends State<SavedRecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Recipes"),
      ),
      body: Center(
        child: const Text("This is the Saved Recipe screen"),
      ),
    );
  }
}