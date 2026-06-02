import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projesof/screens/welcome_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('WelcomeScreen', () {
    testWidgets('WS1: renders main title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pump();

      expect(find.text('Welcome to CircleUP'), findsOneWidget);
    });

    testWidgets('WS2: renders description text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pump();

      expect(
        find.text(
          'Join circles, complete daily challenges and keep your streak alive with friends.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('WS3: renders buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pump();

      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('WS4: renders main structure widgets', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}