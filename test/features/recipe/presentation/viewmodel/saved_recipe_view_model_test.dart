import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/recipe/domain/entity/saved_recipe_entity.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/saved_recipe_view_model.dart';

// ── Fake SavedRecipeViewModel — never hits the API ──
class FakeSavedRecipeViewModel extends SavedRecipeViewModel {
  @override
  List<SavedRecipeEntity> build() => [];

  @override
  Future<void> fetchSavedRecipes() async {}
}

void main() {
  late ProviderContainer container;

  final testRecipe = SavedRecipeEntity(
    id: '1',
    title: 'Dal Bhat',
    image: '/uploads/dalbhat.jpg',
    category: 'Main Course',
    description: 'Classic Nepali meal',
    ingredients: const [],
    instructions: const [],
  );

  final anotherRecipe = SavedRecipeEntity(
    id: '2',
    title: 'Momo',
    image: '/uploads/momo.jpg',
    category: 'Snacks',
    description: 'Steamed dumplings',
    ingredients: const [],
    instructions: const [],
  );

  setUp(() {
    container = ProviderContainer(
      overrides: [
        savedRecipeProvider.overrideWith(() => FakeSavedRecipeViewModel()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'initial state should be an empty list',
    () {
      final state = container.read(savedRecipeProvider);
      expect(state, isEmpty);
    },
  );

  test(
    'isSaved should return true when recipe exists in state',
    () {
      // Manually set the state to include the test recipe
      container.read(savedRecipeProvider.notifier).state = [testRecipe];

      final result =
          container.read(savedRecipeProvider.notifier).isSaved(testRecipe.id);

      expect(result, true);
    },
  );

  test(
    'isSaved should return false when recipe does not exist in state',
    () {
      // no recipes saved
      final result =
          container.read(savedRecipeProvider.notifier).isSaved('999');

      expect(result, false);
    },
  );
}