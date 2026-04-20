import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:projesof/screens/login_screen.dart';
import 'package:projesof/services/auth_service.dart';

void main() {
  late AuthService mockAuthService;

  setUp(() {
    mockAuthService = AuthService(auth: MockFirebaseAuth());
  });

  group('LoginScreen', () {

    testWidgets('LS1: Renders email and password fields', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('LS2: Renders Log In button', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('LS3: Shows errors when submitting empty form', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LS4: Shows error for invalid email format', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'notanemail');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('LS5: Shows error for short password', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('LS6: No validation errors when form is valid', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('LS7: Sign up link is visible', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: mockAuthService)));
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsOneWidget);
    });

  });
}