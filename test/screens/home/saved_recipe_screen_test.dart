import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/recipe/domain/entity/saved_recipe_entity.dart';
import 'package:nepabite/features/recipe/presentation/viewmodel/saved_recipe_view_model.dart';
import 'package:nepabite/screens/home/saved_recipe_screen.dart';

// ── Fake SavedRecipeViewModel — never calls API ──
class FakeSavedRecipeViewModel extends SavedRecipeViewModel {
  @override
  List<SavedRecipeEntity> build() => [];

  @override
  Future<void> fetchSavedRecipes() async {}

  @override
  bool isSaved(String id) => false;
}

Future<void> pumpSavedRecipeScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        savedRecipeProvider.overrideWith(() => FakeSavedRecipeViewModel()),
      ],
      child: const MaterialApp(home: SavedRecipeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'SavedRecipeScreen renders without crashing',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'SavedRecipeScreen shows Saved Recipes as AppBar title',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.text('Saved Recipes'), findsOneWidget);
    },
  );

  testWidgets(
    'SavedRecipeScreen shows empty state when no recipes are saved',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.text('No saved recipes yet'), findsOneWidget);
    },
  );

  testWidgets(
    'SavedRecipeScreen empty state shows correct subtitle',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.text('Recipes you save will appear here'), findsOneWidget);
    },
  );

  testWidgets(
    'SavedRecipeScreen empty state shows bookmark icon',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'SavedRecipeScreen AppBar has white background',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.white);
    },
  );

  testWidgets(
    'SavedRecipeScreen AppBar elevation is zero',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 0);
    },
  );

  testWidgets(
    'SavedRecipeScreen background color matches design system',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF7FAF8));
    },
  );

  testWidgets(
    'SavedRecipeScreen does not show delete button when list is empty',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    },
  );

  testWidgets(
    'SavedRecipeScreen does not show ListView when list is empty',
    (WidgetTester tester) async {
      await pumpSavedRecipeScreen(tester);
      expect(find.byType(ListView), findsNothing);
    },
  );
}