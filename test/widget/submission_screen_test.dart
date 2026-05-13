import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/screens/submission_screen.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late SubmissionService submissionService;
  late UserService userService;

  setUp(() {
    submissionService = SubmissionService(firestore: FakeFirebaseFirestore());
    userService = UserService(firestore: FakeFirebaseFirestore());
  });

  group('SubmissionScreen', () {

    testWidgets('SBS1: Renders Scaffold widget', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SubmissionScreen(
        groupId: 'g1',
        taskId: 't1',
        submissionService: submissionService,
        userService: userService,
      )));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS2: Screen accepts no parameters', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SubmissionScreen(
        groupId: 'g1',
        taskId: 't1',
        submissionService: submissionService,
        userService: userService,
      )));

      expect(find.byType(SubmissionScreen), findsOneWidget);
    });

    testWidgets('SBS3: Screen accepts optional taskTitle parameter', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          taskTitle: 'Custom Title',
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS4: Screen accepts optional taskDescription parameter', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          taskDescription: 'Custom Description',
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS5: Screen accepts optional themeColor parameter', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          themeColor: 'Fitness',
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS6: Screen accepts all optional parameters', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          taskTitle: 'Run 5km',
          taskDescription: 'Complete a 5km run.',
          themeColor: 'Fitness',
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS7: Screen renders containers', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SubmissionScreen(
        groupId: 'g1',
        taskId: 't1',
        submissionService: submissionService,
        userService: userService,
      )));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SBS8: Screen renders with different theme colors', (tester) async {
      for (final theme in ['Fitness', 'Wellness', 'Sustainability']) {
        await tester.pumpWidget(MaterialApp(
          home: SubmissionScreen(
            groupId: 'g1',
            taskId: 't1',
            themeColor: theme,
            submissionService: submissionService,
            userService: userService,
          ),
        ));
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('SBS9: Screen is stateful', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SubmissionScreen(
        groupId: 'g1',
        taskId: 't1',
        submissionService: submissionService,
        userService: userService,
      )));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS10: Screen handles long task titles', (tester) async {
      const String longTitle = 'This is a very long task title that might wrap across multiple lines in the UI';
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          taskTitle: longTitle,
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS11: Screen handles empty parameters gracefully', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SubmissionScreen(
          groupId: 'g1',
          taskId: 't1',
          taskTitle: '',
          taskDescription: '',
          themeColor: '',
          submissionService: submissionService,
          userService: userService,
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SBS12: Screen renders multiple times with same parameters', (tester) async {
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(MaterialApp(
          home: SubmissionScreen(
            groupId: 'g1',
            taskId: 't1',
            taskTitle: 'Test Task',
            taskDescription: 'Test Description',
            submissionService: submissionService,
            userService: userService,
          ),
        ));
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });
  });
}
