import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/recipe/domain/entity/recipe_entity.dart';
import 'package:nepabite/features/recipe/domain/entity/saved_recipe_entity.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/recipe_view_model.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/saved_recipe_view_model.dart';
import 'package:nepabite/screens/home/homepage_screen.dart';

// ── Fake ViewModels that return empty lists and never call the API ──

class FakeRecipeViewModel extends RecipeViewModel {
  @override
  List<RecipeEntity> build() => [];

  @override
  Future<void> fetchRecipes() async {}
}

class FakeSavedRecipeViewModel extends SavedRecipeViewModel {
  @override
  List<SavedRecipeEntity> build() => [];

  @override
  Future<void> fetchSavedRecipes() async {}

  @override
  bool isSaved(String id) => false;
}

// ── Helper ──

Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        recipeViewModelProvider
            .overrideWith(() => FakeRecipeViewModel()),
        savedRecipeProvider
            .overrideWith(() => FakeSavedRecipeViewModel()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'HomeScreen renders without crashing',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows greeting text Namaste',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.textContaining('Namaste'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows subtitle what are you cooking today',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('What are you cooking today?'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows search bar',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen search bar accepts typed input',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      await tester.enterText(find.byType(TextField).first, 'momo');
      await tester.pump();
      expect(find.text('momo'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows shuffle dice button in header',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('🎲'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen tapping shuffle button does not crash',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      await tester.tap(find.text('🎲'));
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows notifications icon in header',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows All Recipes label',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('All Recipes'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows bottom navigation bar',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen bottom nav has Home, Cart, Saved and Profile tabs',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows loading spinner when recipes list is empty',
    (WidgetTester tester) async {
      await pumpHomeScreen(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

}