import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/vote_model.dart';

void main() {
  final now = Timestamp.now();

  group('VoteModel', () {
    test('VM1: constructor stores all fields', () {
      final vote = VoteModel(
        voterId: 'uid2',
        vote: 'VALID',
        votedAt: now,
      );

      expect(vote.voterId, 'uid2');
      expect(vote.vote, 'VALID');
    });

    test('VM2: toFirestore returns correct map', () {
      final vote = VoteModel(voterId: 'uid2', vote: 'INVALID', votedAt: now);
      final map = vote.toFirestore();

      expect(map['vote'], 'INVALID');
      expect(map['votedAt'], now);
    });

    test('VM3: fromFirestore reconstructs the model', () {
      final data = {'vote': 'VALID', 'votedAt': now};
      final vote = VoteModel.fromFirestore(data, 'uid2');

      expect(vote.voterId, 'uid2');
      expect(vote.vote, 'VALID');
    });

    test('VM4: fromFirestore handles missing fields with defaults', () {
      final vote = VoteModel.fromFirestore({}, 'uid3');

      expect(vote.vote, '');
    });

    test('VM5: VALID and INVALID are the accepted vote values', () {
      final valid = VoteModel(voterId: 'u1', vote: 'VALID', votedAt: now);
      final invalid = VoteModel(voterId: 'u1', vote: 'INVALID', votedAt: now);

      expect(valid.vote, 'VALID');
      expect(invalid.vote, 'INVALID');
    });
  });
}
