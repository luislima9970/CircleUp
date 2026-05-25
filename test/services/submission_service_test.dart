import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/models/vote_model.dart';
import 'package:projesof/services/submission_service.dart';

SubmissionModel makeSubmission({String userId = 'uid1'}) => SubmissionModel(
      userId: userId,
      photoUrl: 'https://proof.jpg',
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SubmissionService submissionService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    submissionService = SubmissionService(firestore: fakeFirestore);
  });

  group('SubmissionService', () {
    test('SS1: createSubmission returns the author userId as id', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );
      expect(id, 'uid1');
    });

    test('SS2: createSubmission sets status PENDING and votes to 0', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      final doc = await submissionService.getSubmissionByUser(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(doc, isNotNull);
      expect(doc!.status, 'PENDING');
      expect(doc.validVotes, 0);
      expect(doc.invalidVotes, 0);
    });

    test('SS3: createSubmission throws if same user submits twice', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      expect(
        () => submissionService.createSubmission(
          groupId: 'g1',
          taskId: 't1',
          submission: makeSubmission(),
        ),
        throwsException,
      );
    });

    test('SS4: updateSubmissionStatus changes status to APPROVED', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      await submissionService.updateSubmissionStatus(
        groupId: 'g1',
        taskId: 't1',
        userId: 'uid1',
        status: 'APPROVED',
      );

      final doc = await submissionService.getSubmissionByUser(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(doc!.status, 'APPROVED');
    });

    test('SS5: incrementVoteCount increments validVotes', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      await submissionService.incrementVoteCount(
        groupId: 'g1',
        taskId: 't1',
        authorId: 'uid1',
        isValid: true,
      );

      final doc = await submissionService.getSubmissionByUser(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(doc!.validVotes, 1);
      expect(doc.invalidVotes, 0);
    });

    test('SS6: incrementVoteCount increments invalidVotes', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      await submissionService.incrementVoteCount(
        groupId: 'g1',
        taskId: 't1',
        authorId: 'uid1',
        isValid: false,
      );

      final doc = await submissionService.getSubmissionByUser(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(doc!.invalidVotes, 1);
      expect(doc.validVotes, 0);
    });

    test('SS7: voteSubmission records a vote document', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      await submissionService.voteSubmission(
        groupId: 'g1',
        taskId: 't1',
        authorId: 'uid1',
        voterId: 'uid2',
        vote: VoteModel(voterId: 'uid2', vote: 'VALID', votedAt: Timestamp.now()),
      );

      final vote = await submissionService.getVoteByUser(
        groupId: 'g1',
        taskId: 't1',
        authorId: 'uid1',
        voterId: 'uid2',
      );
      expect(vote, isNotNull);
      expect(vote!.vote, 'VALID');
    });

    test('SS8: getVotesForSubmission returns all votes', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      for (final voterId in ['uid2', 'uid3', 'uid4']) {
        await submissionService.voteSubmission(
          groupId: 'g1',
          taskId: 't1',
          authorId: 'uid1',
          voterId: voterId,
          vote: VoteModel(
              voterId: voterId, vote: 'VALID', votedAt: Timestamp.now()),
        );
      }

      final votes = await submissionService.getVotesForSubmission(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(votes.length, 3);
    });

    test('SS9: deleteSubmission removes the submission', () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      await submissionService.deleteSubmission(
          groupId: 'g1', taskId: 't1', userId: 'uid1');

      final doc = await submissionService.getSubmissionByUser(
          groupId: 'g1', taskId: 't1', userId: 'uid1');
      expect(doc, isNull);
    });

    test('SS10: hasUserSubmittedForTask returns false before submission',
        () async {
      final result = await submissionService.hasUserSubmittedForTask(
          groupId: 'g1', taskId: 't1', authorId: 'uid1');
      expect(result, false);
    });

    test('SS11: hasUserSubmittedForTask returns true after submission',
        () async {
      await submissionService.createSubmission(
        groupId: 'g1',
        taskId: 't1',
        submission: makeSubmission(),
      );

      final result = await submissionService.hasUserSubmittedForTask(
          groupId: 'g1', taskId: 't1', authorId: 'uid1');
      expect(result, true);
    });
  });
}
