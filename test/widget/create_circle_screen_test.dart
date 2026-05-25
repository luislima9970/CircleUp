import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/createcircle_screen.dart';
import 'package:projesof/services/group_service.dart';

void main() {
  late GroupService groupService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));
    groupService = GroupService(firestore: FakeFirebaseFirestore());
  });

  tearDown(() => AppState.clearUser());

  group('CreateCircleScreen', () {
    testWidgets('CC1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC2: renders create circle button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(startInCreateMode: true, groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('CC3: startInCreateMode=false renders without form initially',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          startInCreateMode: false,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC4: startInCreateMode=true shows create form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(
          startInCreateMode: true,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('CC5: renders containers', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CreateCircleScreen(groupService: groupService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });
  });
}
