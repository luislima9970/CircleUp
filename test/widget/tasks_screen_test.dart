import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/tasks_screen.dart';
import 'package:projesof/services/group_service.dart';

void main() {
  late GroupService groupService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));
    groupService = GroupService(firestore: FakeFirebaseFirestore());
  });

  tearDown(() => AppState.clearUser());

  group('TasksPageScreen', () {
    testWidgets('TS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TS2: shows loading indicator before data arrives',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TS3: renders All Tasks title after data loads', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All Tasks'), findsOneWidget);
    });

    testWidgets('TS4: renders Tasks separated by group subtitle',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tasks separated by group'), findsOneWidget);
    });

    testWidgets('TS5: renders back button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('TS6: renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('TS7: renders SafeArea', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}
