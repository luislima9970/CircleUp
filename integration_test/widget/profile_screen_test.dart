import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/profile_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      phrase: 'Hello world',
      createdAt: Timestamp.now(),
    ));
  });

  tearDown(() => AppState.clearUser());

  group('ProfileScreen', () {
    testWidgets('PS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProfileScreen(),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PS2: renders username', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('alice'), findsWidgets);
    });

    testWidgets('PS3: renders phrase', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('PS4: renders Edit Profile button', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('PS5: renders Logout card', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
