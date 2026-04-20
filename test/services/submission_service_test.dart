import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/services/submission_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SubmissionService submissionService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    submissionService = SubmissionService(firestore: fakeFirestore);
  });

  group('SubmissionService', () {

    test('SS1: createSubmission returns a non-empty id', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );
      expect(id, isNotEmpty);
    });

    test('SS2: createSubmission sets status PENDING and votes to 0', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.data()?['status'], 'PENDING');
      expect(doc.data()?['validVotes'], 0);
      expect(doc.data()?['invalidVotes'], 0);
    });

    test('SS3: updateSubmissionStatus changes status to APPROVED', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      await submissionService.updateSubmissionStatus(
        groupId: 'g1', taskId: 't1',
        submissionId: id, status: 'APPROVED',
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.data()?['status'], 'APPROVED');
    });

    test('SS4: voteSubmission increments validVotes on VALID vote', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      await submissionService.voteSubmission(
        groupId: 'g1', taskId: 't1',
        submissionId: id, voterId: 'uid2', vote: 'VALID',
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.data()?['validVotes'], 1);
      expect(doc.data()?['invalidVotes'], 0);
    });

    test('SS5: voteSubmission increments invalidVotes on INVALID vote', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      await submissionService.voteSubmission(
        groupId: 'g1', taskId: 't1',
        submissionId: id, voterId: 'uid2', vote: 'INVALID',
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.data()?['invalidVotes'], 1);
      expect(doc.data()?['validVotes'], 0);
    });

    test('SS6: multiple voters accumulate votes independently', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      await submissionService.voteSubmission(
        groupId: 'g1', taskId: 't1',
        submissionId: id, voterId: 'uid2', vote: 'VALID',
      );
      await submissionService.voteSubmission(
        groupId: 'g1', taskId: 't1',
        submissionId: id, voterId: 'uid3', vote: 'VALID',
      );
      await submissionService.voteSubmission(
        groupId: 'g1', taskId: 't1',
        submissionId: id, voterId: 'uid4', vote: 'INVALID',
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.data()?['validVotes'], 2);
      expect(doc.data()?['invalidVotes'], 1);
    });

    test('SS7: deleteSubmission removes the submission', () async {
      final id = await submissionService.createSubmission(
        groupId: 'g1', taskId: 't1',
        authorId: 'uid1', authorUsername: 'alice',
        proofUrl: 'https://proof.jpg',
      );

      await submissionService.deleteSubmission(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );

      final doc = await submissionService.getSubmissionById(
        groupId: 'g1', taskId: 't1', submissionId: id,
      );
      expect(doc.exists, false);
    });

  });
}
