import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/services/user_service.dart';

UserModel makeUser({
  String id = 'uid1',
  String username = 'alice',
  String email = 'alice@email.com',
}) =>
    UserModel(
      id: id,
      username: username,
      email: email,
      createdAt: Timestamp.now(),
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService userService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(firestore: fakeFirestore);
  });

  group('UserService', () {
    test('US1: createUser stores user in Firestore with correct fields',
        () async {
      final user = makeUser();
      await userService.createUser(user: user);

      final doc =
          await fakeFirestore.collection('users').doc('uid1').get();
      expect(doc.exists, true);
      expect(doc.data()?['username'], 'alice');
      expect(doc.data()?['email'], 'alice@email.com');
    });

    test('US2: getUserById returns the correct user', () async {
      await userService.createUser(user: makeUser());

      final result = await userService.getUserById('uid1');
      expect(result, isNotNull);
      expect(result!.username, 'alice');
    });

    test('US3: getUserById returns null for unknown uid', () async {
      final result = await userService.getUserById('unknown_uid');
      expect(result, isNull);
    });

    test('US4: getUserById returns null for null uid', () async {
      final result = await userService.getUserById(null);
      expect(result, isNull);
    });

    test('US5: updateUsername changes the username correctly', () async {
      await userService.createUser(user: makeUser());

      await userService.updateUsername(uid: 'uid1', username: 'alice_updated');

      final result = await userService.getUserById('uid1');
      expect(result!.username, 'alice_updated');
    });

    test('US6: updatePhotoUrl stores the photo URL', () async {
      await userService.createUser(user: makeUser());

      await userService.updatePhotoUrl(
          uid: 'uid1', photoUrl: 'https://photo.jpg');

      final doc =
          await fakeFirestore.collection('users').doc('uid1').get();
      expect(doc.data()?['photoUrl'], 'https://photo.jpg');
    });

    test('US7: deleteUser removes the user from Firestore', () async {
      await userService.createUser(user: makeUser());

      await userService.deleteUser('uid1');

      final result = await userService.getUserById('uid1');
      expect(result, isNull);
    });

    test('US8: createUser with all optional fields stores them correctly',
        () async {
      final user = UserModel(
        id: 'uid2',
        username: 'bob',
        email: 'bob@email.com',
        phrase: 'Hello world',
        totalPoints: 100,
        maxStreak: 5,
        createdAt: Timestamp.now(),
      );
      await userService.createUser(user: user);

      final result = await userService.getUserById('uid2');
      expect(result!.phrase, 'Hello world');
      expect(result.totalPoints, 100);
      expect(result.maxStreak, 5);
    });
  });
}
