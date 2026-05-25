import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/vote_model.dart';
import '../models/submission_model.dart';

class SubmissionService {
  final CollectionReference<Map<String, dynamic>> _groups;

  SubmissionService({FirebaseFirestore? firestore})
      : _groups =
            (firestore ?? FirebaseFirestore.instance).collection('groups');

  Future<String> createSubmission({
    required String groupId,
    required String taskId,
    required SubmissionModel submission
  }) async {
    final submissionRef = _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submission.userId);

    final submissionSnap = await submissionRef.get();

    if (submissionSnap.exists) {
      throw Exception('Already submitted');
    }
    await submissionRef.set(submission.toFirestore());
    return submissionRef.id;
  }

  Future<SubmissionModel?> getSubmissionByUser({
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    final doc = await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    return SubmissionModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Stream<List<SubmissionModel>> getSubmissionsForTask({
    required String groupId,
    required String taskId,
  }) {
    return _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return SubmissionModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Stream<List<SubmissionModel>> getSubmissionsForTaskWithStatus({
    required String groupId,
    required String taskId,
    required String status
  }) {
    return _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return SubmissionModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Future<void> updateSubmissionStatus({
    required String groupId,
    required String taskId,
    required String userId,
    required String status,
  }) async {
    await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .update({
      'status': status,
    });
  }

  Future<void> deleteSubmission({
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .delete();
  }

  Future<void> incrementVoteCount({
    required String groupId,
    required String taskId,
    required String authorId,
    required bool isValid,
  }) async {
    await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(authorId)
        .update(isValid
            ? {'validVotes': FieldValue.increment(1)}
            : {'invalidVotes': FieldValue.increment(1)});
  }

  Future<void> voteSubmission({
    required String groupId,
    required String taskId,
    required String authorId,
    required String voterId,
    required VoteModel vote,
  }) async {
    final submissionRef = _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(authorId);

    final voteRef = submissionRef.collection('votes').doc(voterId);

    await voteRef.set(vote.toFirestore());
  }

  Future<List<VoteModel>> getVotesForSubmission({
    required String groupId,
    required String taskId,
    required String userId,
  }) async {
    final snap = await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .collection('votes')
        .get();

    return snap.docs.map((doc) {

      return VoteModel.fromFirestore(
        doc.data(),
        doc.id,
      );

    }).toList();
  }

  Future<VoteModel?> getVoteByUser({
    required String groupId,
    required String taskId,
    required String authorId,
    required String voterId,
  }) async {
    final doc = await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(authorId)
        .collection('votes')
        .doc(voterId)
        .get();

    if (!doc.exists) return null;

    return VoteModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Future<bool> hasUserSubmittedForTask({
    required String groupId,
    required String taskId,
    required String authorId,
  }) async {
    return await getSubmissionByUser(groupId: groupId, taskId: taskId, userId: authorId) != null;
  }
}