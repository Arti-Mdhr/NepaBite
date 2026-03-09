import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/recipe/domain/entity/recipe_entity.dart';
import 'package:nepabite/features/recipe/domain/repository/recipe_repository.dart';
import 'package:nepabite/features/recipe/domain/usecases/get_recipes_usecase.dart';

class MockRecipeRepository extends Mock implements IRecipeRepository {}

void main() {
  late GetRecipesUsecase getRecipesUsecase;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    getRecipesUsecase = GetRecipesUsecase(
      repository: mockRecipeRepository,
    );
  });

  final recipeList = [
    const RecipeEntity(
      id: '1',
      title: 'Dal Bhat',
      description: 'Traditional Nepali meal with lentils and rice.',
      image: 'dalbhat.jpg',
      category: 'Main Course',
      instructions: ['Boil dal', 'Cook rice', 'Serve hot'],
      averageRating: 4.5,
    ),
    const RecipeEntity(
      id: '2',
      title: 'Momo',
      description: 'Steamed dumplings filled with spiced meat.',
      image: 'momo.jpg',
      category: 'Snacks',
      instructions: ['Prepare dough', 'Fill with meat', 'Steam for 15 mins'],
      averageRating: 4.8,
    ),
  ];

  test(
    'should return list of recipes when repository call succeeds',
    () async {
      // arrange
      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => Right(recipeList));

      // act
      final result = await getRecipesUsecase();

      // assert
      expect(result, Right(recipeList));
      verify(() => mockRecipeRepository.getRecipes()).called(1);
    },
  );

  test(
    'should return Failure when fetching recipes fails',
    () async {
      // arrange
      final failure = ApiFailure(message: 'Failed to fetch recipes');

      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await getRecipesUsecase();

      // assert
      expect(result, Left(failure));
      verify(() => mockRecipeRepository.getRecipes()).called(1);
    },
  );

  test(
    'should return an empty list when no recipes exist on the server',
    () async {
      // arrange
      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await getRecipesUsecase();

      // assert
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (recipes) => expect(recipes, isEmpty),
      );
    },
  );

  test(
    'should return correct number of recipes',
    () async {
      // arrange
      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => Right(recipeList));

      // act
      final result = await getRecipesUsecase();

      // assert
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (recipes) => expect(recipes.length, 2),
      );
    },
  );

  test(
    'should not call repository more than once per invocation',
    () async {
      // arrange
      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => Right(recipeList));

      // act
      await getRecipesUsecase();

      // assert
      verify(() => mockRecipeRepository.getRecipes()).called(1);
      verifyNoMoreInteractions(mockRecipeRepository);
    },
  );

  test(
    'should return recipes with correct titles and ratings',
    () async {
      // arrange
      when(() => mockRecipeRepository.getRecipes())
          .thenAnswer((_) async => Right(recipeList));

      // act
      final result = await getRecipesUsecase();

      // assert
      result.fold(
        (failure) => fail('Expected success'),
        (recipes) {
          expect(recipes.first.title, 'Dal Bhat');
          expect(recipes.first.averageRating, 4.5);
          expect(recipes.last.title, 'Momo');
          expect(recipes.last.averageRating, 4.8);
        },
      );
    },
  );
}