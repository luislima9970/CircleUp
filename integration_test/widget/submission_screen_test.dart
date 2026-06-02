import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/submission_screen.dart';
import 'package:projesof/services/submission_service.dart';

TaskModel makeTask({
  String id = 'task1',
  String title = 'Run 5km',
  String objective = 'Complete a 5km run.',
}) =>
    TaskModel(
      id: id,
      title: title,
      objective: objective,
      reward: 10,
      isActive: true,
      createdAt: Timestamp.now(),
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late SubmissionService submissionService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'testuser',
      email: 'test@test.com',
      createdAt: Timestamp.now(),
    ));
    submissionService = SubmissionService(firestore: FakeFirebaseFirestore());
  });

  tearDown(() => AppState.clearUser());

  group('SubmissionScreen', () {
    testWidgets('SBS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(),
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS2: renders task title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(title: 'Drink water'),
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.text('Drink water'), findsOneWidget);
    });

    testWidgets('SBS3: renders with Fitness theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Fitness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS4: renders with Wellness theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Wellness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS5: renders with Sustainability theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Sustainability',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS6: shows task objective', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(objective: 'Do 50 push-ups'),
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.text('Do 50 push-ups'), findsOneWidget);
    });

    testWidgets('SBS7: renders containers', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(),
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SBS8: handles long task titles without crashing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          task: makeTask(title: 'This is a very long task title ' * 3),
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
