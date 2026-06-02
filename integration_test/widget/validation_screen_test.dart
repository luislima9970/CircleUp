import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/validation_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore fakeFirestore;
  late SubmissionService submissionService;
  late GroupService groupService;
  late UserService userService;
  late TaskModel task;

  setUp(() async {
    AppState.setCurrentUser(UserModel(
      id: 'voter_uid',
      username: 'voter',
      email: 'voter@test.com',
      createdAt: Timestamp.now(),
    ));

    fakeFirestore = FakeFirebaseFirestore();
    submissionService = SubmissionService(firestore: fakeFirestore);
    groupService = GroupService(firestore: fakeFirestore);
    userService = UserService(firestore: fakeFirestore);

    task = TaskModel(
      id: 'task1',
      title: 'Drink water',
      objective: 'Drink 2L',
      reward: 10,
      isActive: true,
      createdAt: Timestamp.now(),
    );

    await userService.createUser(
      user: UserModel(
        id: 'author_uid',
        username: 'author',
        email: 'author@test.com',
        createdAt: Timestamp.now(),
      ),
    );

    await submissionService.createSubmission(
      groupId: 'g1',
      taskId: 'task1',
      submission: SubmissionModel(userId: 'author_uid', photoUrl: 'https://proof.jpg'),
    );
  });

  tearDown(() => AppState.clearUser());

  group('ValidationScreen', () {
    testWidgets('VS1: renders Validate Submission header', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Validate Submission'), findsOneWidget);
    });

    testWidgets('VS2: renders Submission Details section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Submission Details'), findsOneWidget);
    });

    testWidgets('VS3: renders Community vote section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Community vote'), findsOneWidget);
    });

    testWidgets('VS4: renders Approve and Reject buttons', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('VS5: renders Pending status badge', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('VS6: back button is visible', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('VS7: renders with Fitness theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'g1',
          task: task,
          authorId: 'author_uid',
          themeColor: 'Fitness',
          submissionService: submissionService,
          groupService: groupService,
          userService: userService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
