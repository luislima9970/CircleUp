import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projesof/services/user_service.dart';
import 'package:projesof/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Acceptance Tests - CircleUP', () {

    setUp(() {
      UserService.reset();
    });

    testWidgets('Test1: App opens and shows the logo in the AppBar', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Test2: App shows a list of 5 tasks', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(5));
    });

    testWidgets('Test3: Each task shows its point value', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('+10 pts'), findsOneWidget);
      expect(find.text('+15 pts'), findsOneWidget);
      expect(find.text('+20 pts'), findsOneWidget);
      expect(find.text('+25 pts'), findsOneWidget);
      expect(find.text('+30 pts'), findsOneWidget);
    });

    testWidgets('Test4: Each task shows the correct title', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('🏃 Do exercise for 10 minutes'), findsOneWidget);
      expect(find.text('📖 Read for 15 minutes'),        findsOneWidget);
      expect(find.text('💧 Drink 2L of water'),          findsOneWidget);
      expect(find.text('🧹 Clean your room'),            findsOneWidget);
      expect(find.text('🎯 Study for 1 hour'),           findsOneWidget);
    });

    testWidgets('Test5: Initial points are 0', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('0 pts'), findsOneWidget);
      expect(find.text('Your Points'), findsOneWidget);
    });

    testWidgets('Test6: All tasks start unchecked', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('Test7: Completing a task marks it with a check icon', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(4));
    });

    testWidgets('Test8: Completing a task adds the correct points', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First task gives 10 pts
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.text('10 pts'), findsOneWidget);
    });

    testWidgets('Test9: Completed task title has strikethrough', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(
        find.text('🏃 Do exercise for 10 minutes')
      );
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('Test10: Completed task cannot be completed again', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Complete the task once
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(find.text('10 pts'), findsOneWidget);

      // Tap again — points should NOT increase
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(find.text('10 pts'), findsOneWidget);
    });

    testWidgets('Test11: Completing multiple tasks accumulates points', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task 1 = 10 pts
      await tester.tap(find.byType(Card).at(0));
      await tester.pumpAndSettle();

      // Task 2 = 15 pts → total 25
      await tester.tap(find.byType(Card).at(1));
      await tester.pumpAndSettle();

      expect(find.text('25 pts'), findsOneWidget);
    });

    testWidgets('Test12: Completing all tasks gives 100 total points', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(Card).at(i));
        await tester.pumpAndSettle();
      }

      // 10 + 15 + 20 + 25 + 30 = 100
      expect(find.text('100 pts'), findsOneWidget);
    });
  });
}