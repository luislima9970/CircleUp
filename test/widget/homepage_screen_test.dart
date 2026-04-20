import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/screens/homepage_screen.dart';

void main() {
  group('HomepageScreen', () {

    testWidgets('HS1: Renders title and subtitle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Homepage'), findsOneWidget);
      expect(find.text('Stay on top of your circles'), findsOneWidget);
    });

    testWidgets('HS2: Renders Your Circles section with See all', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Your Circles'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('HS3: Renders Create Group and Join Group buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Group'), findsOneWidget);
      expect(find.text('Join Group'), findsOneWidget);
    });

    testWidgets('HS4: Renders Pending Tasks section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pending Tasks'), findsOneWidget);
    });

    testWidgets('HS5: Renders bottom navigation bar with 4 items', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Circles'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('HS6: Tapping Create Group navigates to CreateCirclePage', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomepageScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Group'));
      await tester.pumpAndSettle();

      expect(find.text('Create Your Circle'), findsOneWidget);
    });

  });
}