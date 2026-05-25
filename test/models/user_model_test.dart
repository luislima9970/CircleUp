import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/user_model.dart';

void main() {
  final now = Timestamp.now();

  group('UserModel', () {
    test('UM1: constructor stores all fields', () {
      final user = UserModel(
        id: 'uid1',
        username: 'alice',
        email: 'alice@test.com',
        photoUrl: 'https://photo.jpg',
        phrase: 'Hello',
        totalPoints: 10,
        maxStreak: 3,
        createdAt: now,
      );

      expect(user.id, 'uid1');
      expect(user.username, 'alice');
      expect(user.email, 'alice@test.com');
      expect(user.photoUrl, 'https://photo.jpg');
      expect(user.phrase, 'Hello');
      expect(user.totalPoints, 10);
      expect(user.maxStreak, 3);
    });

    test('UM2: default values are correct', () {
      final user =
          UserModel(username: 'bob', email: 'bob@test.com', createdAt: now);

      expect(user.phrase, '');
      expect(user.totalPoints, 0);
      expect(user.maxStreak, 0);
      expect(user.id, isNull);
    });

    test('UM3: toFirestore returns correct map', () {
      final user = UserModel(
        username: 'alice',
        email: 'alice@test.com',
        phrase: 'Stay fit',
        totalPoints: 5,
        maxStreak: 2,
        createdAt: now,
      );
      final map = user.toFirestore();

      expect(map['username'], 'alice');
      expect(map['email'], 'alice@test.com');
      expect(map['phrase'], 'Stay fit');
      expect(map['totalPoints'], 5);
      expect(map['maxStreak'], 2);
    });

    test('UM4: fromFirestore reconstructs the model correctly', () {
      final data = {
        'username': 'alice',
        'email': 'alice@test.com',
        'photoUrl': 'https://photo.jpg',
        'phrase': 'Stay fit',
        'totalPoints': 50,
        'maxStreak': 7,
        'createdAt': now,
      };
      final user = UserModel.fromFirestore(data, 'uid1');

      expect(user.id, 'uid1');
      expect(user.username, 'alice');
      expect(user.totalPoints, 50);
      expect(user.maxStreak, 7);
    });

    test('UM5: fromFirestore handles missing fields with defaults', () {
      final user = UserModel.fromFirestore({}, 'uid2');

      expect(user.username, '');
      expect(user.email, '');
      expect(user.totalPoints, 0);
      expect(user.maxStreak, 0);
    });
  });
}
