import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepabite/features/auth/presentation/pages/sign_up_screen.dart';

void main() {
  testWidgets(
    'SignupScreen renders required widgets',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Namaste🙏'), findsOneWidget);
      expect(find.text('Create an Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6));
    },
  );
}
