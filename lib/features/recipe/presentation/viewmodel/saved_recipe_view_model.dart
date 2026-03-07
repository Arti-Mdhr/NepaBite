import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/features/recipe/data/datasource/saved_recipe_remote_datasource.dart';
import '../../domain/entity/saved_recipe_entity.dart';

final savedRecipeProvider =
    NotifierProvider<SavedRecipeViewModel, List<SavedRecipeEntity>>(
        SavedRecipeViewModel.new);

class SavedRecipeViewModel extends Notifier<List<SavedRecipeEntity>> {

  late SavedRecipeRemoteDatasource api;

  @override
  List<SavedRecipeEntity> build() {
    api = SavedRecipeRemoteDatasource(ref.read(apiClientProvider));
    return [];
  }

  Future<void> fetchSavedRecipes() async {
    try {
      final recipes = await api.getSavedRecipes();

      state = recipes.map<SavedRecipeEntity>((r) {
        return SavedRecipeEntity(
          id: r["_id"],
          title: r["title"],
          image: r["image"],
          category: r["category"],
          description: r["description"],
          ingredients: List<Map<String, dynamic>>.from(r["ingredients"] ?? []),
          instructions: List<String>.from(r["instructions"] ?? []),
        );
      }).toList();

    } catch (e) {
      print("Failed to fetch saved recipes: $e");
    }
  }

  Future<void> saveRecipe(SavedRecipeEntity recipe) async {
    try {
      await api.saveRecipe(recipe.id);

      state = [...state, recipe];

    } catch (e) {
      print("Failed to save recipe: $e");
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      await api.removeRecipe(id);

      state = state.where((r) => r.id != id).toList();

    } catch (e) {
      print("Failed to remove recipe: $e");
    }
  }

  bool isSaved(String id) {
    return state.any((r) => r.id == id);
  }
}