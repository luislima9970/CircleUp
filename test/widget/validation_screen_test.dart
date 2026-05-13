import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/screens/validation_screen.dart';
import 'package:projesof/services/submission_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SubmissionService submissionService;
  late String submissionId;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    submissionService = SubmissionService(firestore: fakeFirestore);

    // Cria uma submissão de teste
    submissionId = await submissionService.createSubmission(
      groupId: 'test_group_id',
      taskId: 'test_task_id',
      authorId: 'uid1',
      authorUsername: 'alice',
      proofUrl: 'https://proof.jpg',
    );
  });

  group('ValidationScreen', () {

    testWidgets('VS1: Renders Validate Submission header', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Validate Submission'), findsOneWidget);
    });

    testWidgets('VS2: Renders Submission Details section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Submission Details'), findsOneWidget);
    });

    testWidgets('VS3: Renders author username', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('alice'), findsOneWidget);
    });

    testWidgets('VS4: Renders Community vote section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Community vote'), findsOneWidget);
    });

    testWidgets('VS5: Renders Aceitar and Rejeitar buttons when not voted', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('VS6: Renders Pending status badge', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('VS7: Back button is visible', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          submissionId: submissionId,
          submissionService: submissionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

  });
}