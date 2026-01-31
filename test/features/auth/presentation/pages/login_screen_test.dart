import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets(
    'LoginScreen renders required widgets',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Namaste🙏'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    },
  );

  testWidgets(
    'LoginScreen shows validation error when fields are empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // tap Sign In without entering anything
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // expect validation messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    },
  );
}
