import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/recipe/domain/entity/recipe_entity.dart';
import 'package:nepabite/features/recipe/domain/repository/recipe_repository.dart';
import '../datasource/recipe_remote_datasource.dart';

final recipeRepositoryProvider = Provider<IRecipeRepository>((ref) {
  return RecipeRepositoryImpl(
    remoteDatasource: ref.read(recipeRemoteDatasourceProvider),
  );
});

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeRemoteDatasource _remoteDatasource;

  RecipeRepositoryImpl({required RecipeRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, List<RecipeEntity>>> getRecipes() async {
    try {
      final models = await _remoteDatasource.getRecipes();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}