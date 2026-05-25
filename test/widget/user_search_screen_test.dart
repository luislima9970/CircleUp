import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/user_search_screen.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late UserService userService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));
    userService = UserService(firestore: FakeFirebaseFirestore());
  });

  tearDown(() => AppState.clearUser());

  group('UserSearchScreen', () {
    testWidgets('USS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('USS2: renders search text field', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('USS3: renders Search Users hint text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      expect(find.text('Search by username'), findsOneWidget);
    });

    testWidgets('USS4: accepts search text input', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'bob');

      expect(find.text('bob'), findsWidgets);
    });

    testWidgets('USS5: renders back button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('USS6: renders search icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UserSearchScreen(userService: userService),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
    });
  });
}
