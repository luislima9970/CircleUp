import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:projesof/screens/createcircle_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late GroupService mockGroupService;
  late UserService mockUserService;

  setUp(() {
    mockGroupService = GroupService(firestore: FakeFirebaseFirestore());
    mockUserService = UserService(firestore: FakeFirebaseFirestore());
  });

  group('CreateCircleScreen', () {
    testWidgets('CC1: renders scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          groupService: mockGroupService,
          userService: mockUserService,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC3: accepts optional parameters', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          startInCreateMode: false,
          groupService: mockGroupService,
          userService: mockUserService,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC4: create mode works', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          startInCreateMode: true,
          groupService: mockGroupService,
          userService: mockUserService,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC5: works with injected services only', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          groupService: mockGroupService,
          userService: mockUserService,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC6: renders containers', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          groupService: mockGroupService,
          userService: mockUserService,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(Container), findsWidgets);
    });
  });
}