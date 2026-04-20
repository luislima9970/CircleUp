import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionService {
  final FirebaseFirestore _firestore;

  SubmissionService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createSubmission({
    required String groupId,
    required String taskId,
    required String authorId,
    required String authorUsername,
    required String proofUrl,
  }) async {
    final submissionRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc();

    await submissionRef.set({
      'authorId': authorId,
      'authorUsername': authorUsername,
      'proofUrl': proofUrl,
      'timestamp': Timestamp.now(),
      'status': 'PENDING',
      'validVotes': 0,
      'invalidVotes': 0,
    });

    return submissionRef.id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSubmissionById({
    required String groupId,
    required String taskId,
    required String submissionId,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSubmissionsForTask({
    required String groupId,
    required String taskId,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .get();
  }

  Future<void> updateSubmissionStatus({
    required String groupId,
    required String taskId,
    required String submissionId,
    required String status,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId)
        .update({
      'status': status,
    });
  }

  Future<void> deleteSubmission({
    required String groupId,
    required String taskId,
    required String submissionId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId)
        .delete();
  }

  Future<void> voteSubmission({
    required String groupId,
    required String taskId,
    required String submissionId,
    required String voterId,
    required String vote,
  }) async {
    final submissionRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId);

    final voteRef = submissionRef.collection('votes').doc(voterId);

    await voteRef.set({
      'vote': vote,
      'votedAt': Timestamp.now(),
    });

    if (vote == 'VALID') {
      await submissionRef.update({
        'validVotes': FieldValue.increment(1),
      });
    } else if (vote == 'INVALID') {
      await submissionRef.update({
        'invalidVotes': FieldValue.increment(1),
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getVotesForSubmission({
    required String groupId,
    required String taskId,
    required String submissionId,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId)
        .collection('votes')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getVoteByUser({
    required String groupId,
    required String taskId,
    required String submissionId,
    required String voterId,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(submissionId)
        .collection('votes')
        .doc(voterId)
        .get();
  }
}