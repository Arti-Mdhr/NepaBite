import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/cart/domain/entity/cart_item_entity.dart';
import 'package:nepabite/features/cart/presentation/viewmodel/cart_view_model.dart';
import 'package:nepabite/screens/home/cart_screen.dart';

// ── Fake CartViewModel — never calls API ──
class FakeCartViewModel extends CartViewModel {
  @override
  List<CartItemEntity> build() => [];

  @override
  Future<void> fetchCart() async {}
}

Future<void> pumpCartScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cartProvider.overrideWith(() => FakeCartViewModel()),
      ],
      child: const MaterialApp(home: CartScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'CartScreen renders without crashing',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );

  testWidgets(
    'CartScreen shows Ingredient Grocery List as AppBar title',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.text('Ingredient Grocery List'), findsOneWidget);
    },
  );

  testWidgets(
    'CartScreen shows empty state when cart is empty',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.text('Your list is empty'), findsOneWidget);
    },
  );

  testWidgets(
    'CartScreen empty state shows add ingredients hint',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.text('Add ingredients from a recipe'), findsOneWidget);
    },
  );

  testWidgets(
    'CartScreen empty state shows shopping cart icon',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    },
  );

 
  testWidgets(
    'CartScreen does not show Clear List button when cart is empty',
    (WidgetTester tester) async {
      await pumpCartScreen(tester);
      expect(find.text('Clear List'), findsNothing);
    },
  );
}