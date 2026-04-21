import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService userService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(firestore: fakeFirestore);
  });

  group('UserService', () {

    test('US1: createUser stores user in Firestore with correct fields', () async {
      await userService.createUser(
        uid: 'uid1',
        username: 'alice',
        email: 'alice@email.com',
      );

      final doc = await fakeFirestore.collection('users').doc('uid1').get();
      expect(doc.exists, true);
      expect(doc.data()?['username'], 'alice');
      expect(doc.data()?['email'], 'alice@email.com');
    });

    test('US2: getUserById returns the correct user', () async {
      await userService.createUser(
        uid: 'uid1',
        username: 'alice',
        email: 'alice@email.com',
      );

      final doc = await userService.getUserById('uid1');
      expect(doc.exists, true);
      expect(doc.data()?['username'], 'alice');
    });

    test('US3: getUserById returns non-existent doc for unknown uid', () async {
      final doc = await userService.getUserById('unknown_uid');
      expect(doc.exists, false);
    });

    test('US4: updateUsername changes the username correctly', () async {
      await userService.createUser(
        uid: 'uid1',
        username: 'alice',
        email: 'alice@email.com',
      );

      await userService.updateUsername(uid: 'uid1', username: 'alice_updated');

      final doc = await userService.getUserById('uid1');
      expect(doc.data()?['username'], 'alice_updated');
    });

    test('US5: updatePhotoUrl stores the photo URL', () async {
      await userService.createUser(
        uid: 'uid1',
        username: 'alice',
        email: 'alice@email.com',
      );

      await userService.updatePhotoUrl(
        uid: 'uid1',
        photoUrl: 'https://photo.jpg',
      );

      final doc = await userService.getUserById('uid1');
      expect(doc.data()?['photoUrl'], 'https://photo.jpg');
    });

    test('US6: deleteUser removes the user from Firestore', () async {
      await userService.createUser(
        uid: 'uid1',
        username: 'alice',
        email: 'alice@email.com',
      );

      await userService.deleteUser('uid1');

      final doc = await userService.getUserById('uid1');
      expect(doc.exists, false);
    });

  });
}