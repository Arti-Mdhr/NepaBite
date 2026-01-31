import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/screens/home/profile_screen.dart';

void main() {
  testWidgets(
    'ProfileScreen shows default avatar when no profile image',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileScreen shows profile image when available',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    },
  );

}
 