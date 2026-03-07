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
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  late List<bool> selected;
  late List ingredients;

  @override
  void initState() {
    super.initState();
    final rawIngredients = widget.recipe.ingredients;
    ingredients = (rawIngredients is List) ? rawIngredients : [];
    selected = List.generate(ingredients.length, (_) => false);
  }

  int get selectedCount => selected.where((s) => s).length;

  void _toggleAll(bool value) {
    setState(() {
      selected = List.generate(ingredients.length, (_) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Ingredients",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          if (ingredients.isNotEmpty)
            TextButton(
              onPressed: () =>
                  _toggleAll(selectedCount < ingredients.length),
              child: Text(
                selectedCount == ingredients.length
                    ? "Deselect All"
                    : "Select All",
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: ingredients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: _greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.list_alt_rounded,
                        size: 48, color: _green),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No ingredients found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
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
                final isSelected = selected[index];

                return GestureDetector(
                  onTap: () {
                    setState(() => selected[index] = !selected[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _greenLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _green
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          // Custom checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? _green : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? _green
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isSelected
                                    ? const Color(0xFF0F7A52)
                                    : Colors.black87,
                              ),
                            ),
                          ),

                          if (quantity.toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _green.withOpacity(0.15)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF0F7A52)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            final selectedIngredients = [
              for (int i = 0; i < ingredients.length; i++)
                if (selected[i]) ingredients[i],
            ];

            if (selectedIngredients.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Please select at least one ingredient"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              return;
            }

            ref
                .read(cartProvider.notifier)
                .addIngredients(selectedIngredients);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                      "${selectedIngredients.length} ingredient${selectedIngredients.length == 1 ? '' : 's'} added to cart"),
                ]),
                backgroundColor: _green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Text(
            selectedCount == 0
                ? "Add to Cart"
                : "Add $selectedCount Item${selectedCount == 1 ? '' : 's'} to Cart",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}