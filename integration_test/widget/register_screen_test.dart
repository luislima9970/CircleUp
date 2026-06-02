import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/screens/register_screen.dart';
import 'package:projesof/services/auth_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AuthService authService;
  late UserService userService;

  setUp(() {
    final firestore = FakeFirebaseFirestore();

    authService = AuthService(auth: MockFirebaseAuth());
    userService = UserService(firestore: firestore);
  });

  group('RegisterScreen', () {
    testWidgets('RS1: renders fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(
          authService: authService,
          userService: userService,
        ),
      ));

      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('RS2: empty submit shows errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(
          authService: authService,
          userService: userService,
        ),
      ));

      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pump();

      expect(find.textContaining('enter'), findsWidgets);
    });

    testWidgets('RS3: password mismatch error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(
          authService: authService,
          userService: userService,
        ),
      ));

      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '654321');

      await tester.ensureVisible(find.text('Create Account').last);
      await tester.tap(find.text('Create Account').last);
      await tester.pump();

      expect(find.textContaining('match'), findsOneWidget);
    });
  });
}