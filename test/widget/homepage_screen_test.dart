import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/screens/homepage_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late GroupService mockGroupService;

  setUp(() {
    mockGroupService = GroupService(firestore: FakeFirebaseFirestore());
  });

  group('HomepageScreen', () {

    testWidgets('HS1: Renders bottom navigation bar with 4 items', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: mockGroupService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Circles'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('HS2: Renders Today\'s Progress card', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: mockGroupService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Today\'s Progress'), findsOneWidget);
    });

    testWidgets('HS3: Renders Your Groups section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: mockGroupService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Your Groups'), findsOneWidget);
    });

    testWidgets('HS4: Renders empty groups state when no groups exist', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: mockGroupService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('No groups yet'), findsOneWidget);
    });

    testWidgets('HS5: Renders progress stats boxes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomepageScreen(groupService: mockGroupService),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Points'), findsOneWidget);
    });

  });
}