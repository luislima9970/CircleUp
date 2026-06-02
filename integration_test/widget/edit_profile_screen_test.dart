import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/edit_profile_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/image_upload_service.dart';
import 'package:projesof/services/user_service.dart';

class MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late UserService userService;
  late GroupService groupService;
  late MockImageUploadService mockImageUploadService;

  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      phrase: 'Stay fit',
      createdAt: Timestamp.now(),
    ));
    final fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(firestore: fakeFirestore);
    groupService = GroupService(firestore: fakeFirestore);
    mockImageUploadService = MockImageUploadService();
  });

  tearDown(() => AppState.clearUser());

  Widget buildScreen() => MaterialApp(
        home: EditProfileScreen(
          userService: userService,
          groupService: groupService,
          imageUploadService: mockImageUploadService,
        ),
      );

  group('EditProfileScreen', () {
    testWidgets('EPS1: renders Scaffold', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('EPS2: renders username field pre-filled with current username',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('alice'), findsWidgets);
    });

    testWidgets('EPS3: renders phrase field pre-filled', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('Stay fit'), findsOneWidget);
    });

    testWidgets('EPS4: renders Save Changes button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('EPS5: renders TextFormFields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('EPS6: username field accepts new text', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final usernameField = find.byType(TextFormField).first;
      await tester.enterText(usernameField, 'newname');

      expect(find.text('newname'), findsOneWidget);
    });

    testWidgets('EPS7: shows validation error on empty username submit',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final usernameField = find.byType(TextFormField).first;
      await tester.enterText(usernameField, '');

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(find.text('Enter a username'), findsOneWidget);
    });
  });
}
