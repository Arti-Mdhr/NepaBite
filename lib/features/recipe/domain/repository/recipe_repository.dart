import 'package:dartz/dartz.dart';
import 'package:nepabite/core/errors/failure.dart';
import '../entity/recipe_entity.dart';

abstract interface class IRecipeRepository {
  Future<Either<Failure, List<RecipeEntity>>> getRecipes();
}