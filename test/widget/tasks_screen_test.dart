import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/screens/tasks_screen.dart';

void main() {
  group('TasksPageScreen', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('TS1: Renders back button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('TS2: Renders Tasks separated by group text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tasks separated by group'), findsOneWidget);
    });

    testWidgets('TS3: Renders task page title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All Tasks'), findsOneWidget);
    });

    testWidgets('TS4: Renders ListView for task display', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('TS5: Renders background gradient', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('TS6: Renders loading page when data is loading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));

      // During loading before pumpAndSettle
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('TS7: Page accepts userId parameter', (tester) async {
      const String testUserId = 'custom_user_123';
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: testUserId, firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      // If page renders, userId was accepted
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TS8: Renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('TS9: Page has SafeArea widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('TS10: Renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TasksPageScreen(userId: 'test_user_id', firestore: fakeFirestore),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
