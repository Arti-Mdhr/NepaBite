import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/features/recipe/domain/repository/recipe_repository.dart';
import 'package:nepabite/features/recipe/data/repository/recipe_repository_impl.dart';

final getRecipesUsecaseProvider = Provider<GetRecipesUsecase>((ref) {
  return GetRecipesUsecase(
    repository: ref.read(recipeRepositoryProvider),
  );
});

class GetRecipesUsecase {
  final IRecipeRepository _repository;

  GetRecipesUsecase({required IRecipeRepository repository})
      : _repository = repository;

  Future call() {
    return _repository.getRecipes();
  }
}