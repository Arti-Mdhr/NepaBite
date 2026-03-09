import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/recipe_entity.dart';
import '../../domain/usecases/get_recipes_usecase.dart';

final recipeViewModelProvider =
    NotifierProvider<RecipeViewModel, List<RecipeEntity>>(
  () => RecipeViewModel(),
);

class RecipeViewModel extends Notifier<List<RecipeEntity>> {
  late GetRecipesUsecase _getRecipesUsecase;

  @override
  List<RecipeEntity> build() {
    _getRecipesUsecase = ref.read(getRecipesUsecaseProvider);
    return [];
  }

  Future<void> fetchRecipes() async {
    final result = await _getRecipesUsecase.call();

    result.fold(
      (failure) {},
      (recipes) {
        state = recipes;
      },
    );
  }
}