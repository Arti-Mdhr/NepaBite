import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/features/cart/presentation/viewmodel/cart_view_model.dart';

class RecipeIngredientsScreen extends ConsumerStatefulWidget {
  final dynamic recipe;

  const RecipeIngredientsScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeIngredientsScreen> createState() =>
      _RecipeIngredientsScreenState();
}

class _RecipeIngredientsScreenState
    extends ConsumerState<RecipeIngredientsScreen> {

  late List<bool> selected;
  late List ingredients;

  @override
  void initState() {
    super.initState();
    final rawIngredients = widget.recipe.ingredients;
    ingredients = (rawIngredients is List) ? rawIngredients : [];
    selected = List.generate(ingredients.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredients"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ingredients.isEmpty
          ? const Center(
              child: Text(
                "No ingredients found.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];

                final name = item is Map
                    ? item['name'] ?? 'Unknown'
                    : item.name ?? 'Unknown';

                final quantity = item is Map
                    ? item['quantity'] ?? ''
                    : item.quantity ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    activeColor: const Color(0xFF1EB980),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      quantity,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    value: selected[index],
                    onChanged: (value) {
                      setState(() {
                        selected[index] = value!;
                      });
                    },
                  ),
                );
              },
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1EB980),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Add to Cart",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          onPressed: () {
            final selectedIngredients = [];

            for (int i = 0; i < ingredients.length; i++) {
              if (selected[i]) {
                selectedIngredients.add(ingredients[i]);
              }
            }

            if (selectedIngredients.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select at least one ingredient!"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            ref.read(cartProvider.notifier).addIngredients(selectedIngredients);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Ingredients added to cart!"),
                backgroundColor: Color(0xFF1EB980),
              ),
            );
          },
        ),
      ),
    );
  }
}