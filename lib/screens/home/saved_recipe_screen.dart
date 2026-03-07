import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_endpoints.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/saved_recipe_view_model.dart';
import 'package:nepabite/screens/recipe/recipe_detail_screen.dart';

class SavedRecipeScreen extends ConsumerStatefulWidget {
  const SavedRecipeScreen({super.key});

  @override
  ConsumerState<SavedRecipeScreen> createState() =>
      _SavedRecipeScreenState();
}

class _SavedRecipeScreenState extends ConsumerState<SavedRecipeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(savedRecipeProvider.notifier).fetchSavedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(savedRecipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Recipes"),
      ),

      body: recipes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No saved recipes yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ApiEndpoints.fileUrl(recipe.image),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.fastfood),
                        ),
                      ),
                    ),

                    title: Text(
                      recipe.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(savedRecipeProvider.notifier)
                            .removeRecipe(recipe.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}