import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/submission_model.dart';

void main() {
  group('SubmissionModel', () {
    test('SM1: constructor stores all fields', () {
      final sub = SubmissionModel(
        userId: 'uid1',
        photoUrl: 'https://photo.jpg',
        status: 'PENDING',
        validVotes: 2,
        invalidVotes: 1,
      );

      expect(sub.userId, 'uid1');
      expect(sub.photoUrl, 'https://photo.jpg');
      expect(sub.status, 'PENDING');
      expect(sub.validVotes, 2);
      expect(sub.invalidVotes, 1);
    });

    test('SM2: default status is PENDING and votes are 0', () {
      final sub = SubmissionModel(userId: 'uid1');

      expect(sub.status, 'PENDING');
      expect(sub.validVotes, 0);
      expect(sub.invalidVotes, 0);
    });

    test('SM3: toFirestore returns correct map', () {
      final sub = SubmissionModel(
        userId: 'uid1',
        photoUrl: 'https://photo.jpg',
        status: 'APPROVED',
        validVotes: 3,
        invalidVotes: 0,
      );
      final map = sub.toFirestore();

      expect(map['status'], 'APPROVED');
      expect(map['validVotes'], 3);
      expect(map['invalidVotes'], 0);
    });

    test('SM4: fromFirestore reconstructs the model', () {
      final data = {
        'photoUrl': 'https://proof.jpg',
        'status': 'APPROVED',
        'validVotes': 5,
        'invalidVotes': 1,
      };
      final sub = SubmissionModel.fromFirestore(data, 'uid1');

      expect(sub.userId, 'uid1');
      expect(sub.status, 'APPROVED');
      expect(sub.validVotes, 5);
    });

    test('SM5: status field is mutable', () {
      final sub = SubmissionModel(userId: 'uid1');
      sub.status = 'REJECTED';

      expect(sub.status, 'REJECTED');
    });
  });
}
