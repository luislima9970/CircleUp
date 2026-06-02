import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/group_page.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore fakeFirestore;
  late GroupService groupService;
  late TaskService taskService;
  late UserService userService;
  late SubmissionService submissionService;
  late String groupId;

  setUp(() async {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));

    fakeFirestore = FakeFirebaseFirestore();
    groupService = GroupService(firestore: fakeFirestore);
    taskService = TaskService(firestore: fakeFirestore);
    userService = UserService(firestore: fakeFirestore);
    submissionService = SubmissionService(firestore: fakeFirestore);

    groupId = await groupService.createGroup(
      group: GroupModel(
        name: 'Test Group',
        theme: 'Fitness',
        description: 'A test group',
        createdAt: Timestamp.now(),
      ),
    );

    await groupService.addMemberToGroup(
      groupId: groupId,
      user: AppState.currentUser!,
    );
  });

  tearDown(() => AppState.clearUser());

  group('GroupPageScreen', () {
    testWidgets('GP1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GroupPageScreen(
          groupId: groupId,
          groupService: groupService,
          taskService: taskService,
          userService: userService,
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('GP2: renders group name after loading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GroupPageScreen(
          groupId: groupId,
          groupService: groupService,
          taskService: taskService,
          userService: userService,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Group'), findsWidgets);
    });

    testWidgets('GP3: shows loading indicator initially', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GroupPageScreen(
          groupId: groupId,
          groupService: groupService,
          taskService: taskService,
          userService: userService,
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('GP4: renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GroupPageScreen(
          groupId: groupId,
          groupService: groupService,
          taskService: taskService,
          userService: userService,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('GP5: renders task and leaderboard tabs', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GroupPageScreen(
          groupId: groupId,
          groupService: groupService,
          taskService: taskService,
          userService: userService,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Leaderboard'), findsOneWidget);
    });
  });
}
