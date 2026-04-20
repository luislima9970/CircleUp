import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/screens/register_screen.dart';
import 'package:projesof/services/auth_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late AuthService mockAuthService;
  late UserService mockUserService;

  setUp(() {
    mockAuthService = AuthService(auth: MockFirebaseAuth());
    mockUserService = UserService(firestore: FakeFirebaseFirestore());
  });

  group('RegisterScreen', () {

    testWidgets('RS1: Renders all 4 field labels', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('RS2: Renders Create Account button', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('RS3: Shows errors when submitting empty form', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a username'), findsOneWidget);
      expect(find.text('Please enter an email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('RS4: Shows error for username shorter than 3 characters', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'ab');
      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Username must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('RS5: Shows error for invalid email', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');
      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('RS6: Shows error for password shorter than 6 characters', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'alice@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('RS7: Shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'alice@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'different456');
      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('RS8: No errors when all fields are valid', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterScreen(
        authService: mockAuthService, userService: mockUserService,
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'alice');
      await tester.enterText(find.byType(TextFormField).at(1), 'alice@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsNothing);
      expect(find.text('Please enter a username'), findsNothing);
    });

  });
}