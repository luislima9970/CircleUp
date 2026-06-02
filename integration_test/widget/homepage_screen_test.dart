import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/homepage_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/task_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late GroupService groupService;
  late TaskService taskService;
  late SubmissionService submissionService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));
    final fakeFirestore = FakeFirebaseFirestore();
    groupService = GroupService(firestore: fakeFirestore);
    taskService = TaskService(firestore: fakeFirestore);
    submissionService = SubmissionService(firestore: fakeFirestore);
  });

  tearDown(() => AppState.clearUser());

  group('HomepageScreen', () {
    testWidgets('HS1: renders bottom navigation bar with 4 items',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Circles'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('HS2: renders Your Progress card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Your Progress'), findsOneWidget);
    });

    testWidgets('HS3: renders Your Groups section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Your Groups'), findsOneWidget);
    });

    testWidgets('HS4: renders empty groups state when no groups exist',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('No groups yet'), findsOneWidget);
    });

    testWidgets('HS5: renders progress stat labels', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });

    testWidgets('HS6: renders search icon button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('HS7: renders greeting with username', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: groupService, taskService: taskService, submissionService: submissionService),
      ));
      await tester.pump();

      expect(find.text('Hello, alice'), findsOneWidget);
    });
  });
}
