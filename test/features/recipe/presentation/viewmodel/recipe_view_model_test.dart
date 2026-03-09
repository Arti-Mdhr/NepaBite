import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nepabite/core/errors/failure.dart';
import 'package:nepabite/features/recipe/domain/entity/recipe_entity.dart';
import 'package:nepabite/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/recipe_view_model.dart';

class MockGetRecipesUsecase extends Mock implements GetRecipesUsecase {}

void main() {
  late ProviderContainer container;
  late MockGetRecipesUsecase mockGetRecipesUsecase;

  final recipeList = [
    const RecipeEntity(
      id: '1',
      title: 'Dal Bhat',
      description: 'Traditional Nepali meal',
      image: 'dalbhat.jpg',
      category: 'Main Course',
      averageRating: 4.5,
    ),
    const RecipeEntity(
      id: '2',
      title: 'Momo',
      description: 'Steamed dumplings',
      image: 'momo.jpg',
      category: 'Snacks',
      averageRating: 4.8,
    ),
  ];

  setUp(() {
    mockGetRecipesUsecase = MockGetRecipesUsecase();
    container = ProviderContainer(
      overrides: [
        getRecipesUsecaseProvider
            .overrideWithValue(mockGetRecipesUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'initial state should be an empty list',
    () {
      final state = container.read(recipeViewModelProvider);
      expect(state, isEmpty);
    },
  );

  test(
    'fetchRecipes should update state with recipes on success',
    () async {
      // arrange
      when(() => mockGetRecipesUsecase.call())
          .thenAnswer((_) async => Right(recipeList));

      // act
      await container
          .read(recipeViewModelProvider.notifier)
          .fetchRecipes();

      // assert
      final state = container.read(recipeViewModelProvider);
      expect(state.length, 2);
      expect(state.first.title, 'Dal Bhat');
      expect(state.last.title, 'Momo');
    },
  );

  test(
    'fetchRecipes should keep state empty when usecase returns failure',
    () async {
      // arrange
      when(() => mockGetRecipesUsecase.call()).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to fetch recipes')),
      );

      // act
      await container
          .read(recipeViewModelProvider.notifier)
          .fetchRecipes();

      // assert
      final state = container.read(recipeViewModelProvider);
      expect(state, isEmpty);
    },
  );
}