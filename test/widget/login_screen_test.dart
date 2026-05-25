import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:projesof/screens/login_screen.dart';
import 'package:projesof/services/auth_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late AuthService authService;
  late UserService userService;

  setUp(() {
    authService = AuthService(auth: MockFirebaseAuth());
    userService = UserService(firestore: FakeFirebaseFirestore());
  });

  group('LoginScreen', () {
    testWidgets('LS1: renders fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(authService: authService, userService: userService),
      ));

      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('LS2: shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(authService: authService, userService: userService),
      ));

      await tester.ensureVisible(find.text('Log In').last);
      await tester.tap(find.text('Log In').last);
      await tester.pump();

      expect(find.textContaining('enter'), findsWidgets);
    });

    testWidgets('LS3: shows invalid email error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(authService: authService, userService: userService),
      ));

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.ensureVisible(find.text('Log In').last);
      await tester.tap(find.text('Log In').last);
      await tester.pump();

      expect(find.textContaining('valid email'), findsOneWidget);
    });
  });
}