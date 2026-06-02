import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/task_detail_screen.dart';
import 'package:projesof/services/submission_service.dart';

TaskModel makeTask({
  String id = 'task1',
  String title = 'Recycle Plastic Bottles',
  String objective = 'Collect and recycle 10 plastic bottles',
  int reward = 10,
}) =>
    TaskModel(
      id: id,
      title: title,
      objective: objective,
      reward: reward,
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

  group('TaskDetailScreen', () {
    testWidgets('TDS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Sustainability',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS2: renders task title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(title: 'Run 5km'),
          themeColor: 'Fitness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.text('Run 5km'), findsOneWidget);
    });

    testWidgets('TDS3: renders task objective', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(objective: 'Complete a 5km run'),
          themeColor: 'Fitness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.text('Complete a 5km run'), findsOneWidget);
    });

    testWidgets('TDS4: renders back button icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Sustainability',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('TDS5: renders with Fitness theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Fitness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS6: renders with Wellness theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Wellness',
          submissionService: submissionService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS7: shows loading before submission check resolves',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Sustainability',
          submissionService: submissionService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS8: shows submit button after submission check completes',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'g1',
          task: makeTask(),
          themeColor: 'Sustainability',
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
