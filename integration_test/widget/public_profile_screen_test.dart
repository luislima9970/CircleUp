import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/public_profile_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore fakeFirestore;
  late UserService userService;
  late GroupService groupService;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(firestore: fakeFirestore);
    groupService = GroupService(firestore: fakeFirestore);

    AppState.setCurrentUser(UserModel(
      id: 'viewer_uid',
      username: 'viewer',
      email: 'viewer@test.com',
      createdAt: Timestamp.now(),
    ));

    await userService.createUser(
      user: UserModel(
        id: 'target_uid',
        username: 'bob',
        email: 'bob@test.com',
        phrase: 'Stay active',
        createdAt: Timestamp.now(),
      ),
    );
  });

  tearDown(() => AppState.clearUser());

  group('PublicProfileScreen', () {
    testWidgets('PPS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PPS2: renders Profile title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('PPS3: renders target username', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('bob'), findsWidgets);
    });

    testWidgets('PPS4: renders phrase', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Stay active'), findsOneWidget);
    });

    testWidgets('PPS5: renders back button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('PPS6: shows empty circles card when user has no groups',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No visible circles'), findsOneWidget);
    });

    testWidgets('PPS7: shows groups when user is member', (tester) async {
      final groupId = await groupService.createGroup(
        group: GroupModel(
          name: 'Runners',
          theme: 'Fitness',
          description: 'Run daily',
          createdAt: Timestamp.now(),
        ),
      );
      await groupService.addMemberToGroup(
        groupId: groupId,
        user: UserModel(
          id: 'target_uid',
          username: 'bob',
          email: 'bob@test.com',
          createdAt: Timestamp.now(),
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: PublicProfileScreen(
          userId: 'target_uid',
          userService: userService,
          groupService: groupService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Runners'), findsOneWidget);
    });
  });
}
