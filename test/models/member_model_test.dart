import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/member_model.dart';

void main() {
  final now = Timestamp.now();

  group('MemberModel', () {
    test('MM1: constructor stores all fields', () {
      final member = MemberModel(
        userId: 'uid1',
        username: 'alice',
        photoUrl: 'https://photo.jpg',
        phrase: 'Hello',
        points: 50,
        streak: 5,
        role: 'owner',
        joinedAt: now,
      );

      expect(member.userId, 'uid1');
      expect(member.username, 'alice');
      expect(member.points, 50);
      expect(member.streak, 5);
      expect(member.role, 'owner');
    });

    test('MM2: default values are correct', () {
      final member =
          MemberModel(userId: 'uid1', username: 'bob', joinedAt: now);

      expect(member.points, 0);
      expect(member.streak, 0);
      expect(member.role, 'member');
      expect(member.phrase, '');
    });

    test('MM3: toFirestore returns correct map', () {
      final member = MemberModel(
        userId: 'uid1',
        username: 'alice',
        points: 30,
        streak: 3,
        role: 'owner',
        joinedAt: now,
      );
      final map = member.toFirestore();

      expect(map['username'], 'alice');
      expect(map['points'], 30);
      expect(map['streak'], 3);
      expect(map['role'], 'owner');
    });

    test('MM4: fromFirestore reconstructs the model', () {
      final data = {
        'username': 'alice',
        'photoUrl': '',
        'phrase': 'Stay fit',
        'points': 20,
        'streak': 4,
        'role': 'member',
        'joinedAt': now,
      };
      final member = MemberModel.fromFirestore(data, 'uid1');

      expect(member.userId, 'uid1');
      expect(member.username, 'alice');
      expect(member.points, 20);
    });

    test('MM5: fromFirestore handles missing fields with defaults', () {
      final member = MemberModel.fromFirestore({}, 'uid2');

      expect(member.username, 'User');
      expect(member.points, 0);
      expect(member.streak, 0);
    });
  });
}
