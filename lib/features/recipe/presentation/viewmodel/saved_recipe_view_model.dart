import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/saved_recipe_entity.dart';

final savedRecipeProvider =
    NotifierProvider<SavedRecipeViewModel, List<SavedRecipeEntity>>(
        SavedRecipeViewModel.new);

class SavedRecipeViewModel extends Notifier<List<SavedRecipeEntity>> {

  @override
  List<SavedRecipeEntity> build() {
    return [];
  }

  void saveRecipe(SavedRecipeEntity recipe) {
    state = [...state, recipe];
  }

  void removeRecipe(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  bool isSaved(String id) {
    return state.any((r) => r.id == id);
  }
}