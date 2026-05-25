import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/profile_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/task_service.dart';

void main() {
  late GroupService groupService;
  late TaskService taskService;

  setUp(() {
    final fakeFirestore = FakeFirebaseFirestore();
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      phrase: 'Hello world',
      totalPoints: 42,
      maxStreak: 3,
      createdAt: Timestamp.now(),
    ));
    groupService = GroupService(firestore: fakeFirestore);
    taskService = TaskService(firestore: fakeFirestore);
  });

  tearDown(() => AppState.clearUser());

  group('ProfileScreen', () {
    testWidgets('PS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PS2: renders username', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.text('alice'), findsWidgets);
    });

    testWidgets('PS3: renders phrase', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('PS4: renders Points stat card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.text('Points'), findsOneWidget);
    });

    testWidgets('PS5: renders Streak stat card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('PS6: renders Edit Profile button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pump();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('PS7: renders Logout card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('PS8: renders Progress Summary section after loading',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(
          groupService: groupService,
          taskService: taskService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Progress Summary'), findsOneWidget);
    });
  });
}
