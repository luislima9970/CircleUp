import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/services/submission_service.dart';

class TaskService {
  final SubmissionService _submissionService = SubmissionService();
  final _groups = FirebaseFirestore.instance.collection('groups');

  Future<String> createTask({
    required String groupId,
    required TaskModel task
  }) async {
    final docRef = await _groups.doc(groupId).collection('tasks').add(task.toFirestore());
    return docRef.id;
  }

  Future<TaskModel?> getTaskById({
    required String groupId,
    required String uid
  }) async {

    final doc = await _groups.doc(groupId).collection('tasks').doc(uid).get();

    if (!doc.exists) return null;

    return TaskModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Stream<List<TaskModel>> getTasksForGroup({
    required String groupId
  }) {

    return _groups
        .doc(groupId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return TaskModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Stream<List<TaskModel>> getActiveTasks({
    required String groupId
  }) {

    return _groups
        .doc(groupId)
        .collection('tasks')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return TaskModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Stream<List<TaskModel>> getRemainingTasksForUserInGroup({
    required String groupId,
    required String userId
  }) {

    return _groups
        .doc(groupId)
        .collection('tasks')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {

      final List<TaskModel> tasks = [];

      for (final taskDoc in snapshot.docs) {
        final submission = await _submissionService.getSubmissionByUser(groupId: groupId, taskId: taskDoc.id, userId: userId);
        if (submission?.status != 'APPROVED') tasks.add(TaskModel.fromFirestore(taskDoc.data(), taskDoc.id));
      }
      return tasks;
    });
  }

  Stream<List<TaskModel>> getCompletedTasksForUserInGroup({
    required String groupId,
    required String userId
  }) {

    return _groups
        .doc(groupId)
        .collection('tasks')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {

      final List<TaskModel> tasks = [];

      for (final taskDoc in snapshot.docs) {
        final submission = await _submissionService.getSubmissionByUser(groupId: groupId, taskId: taskDoc.id, userId: userId);
        if (submission?.status == 'APPROVED') tasks.add(TaskModel.fromFirestore(taskDoc.data(), taskDoc.id));
      }
      return tasks;
    });
  }

  Future<List<TaskModel>> getCompletedTasksForUser(
      String? uid,
      ) async {

    final List<TaskModel> tasks = [];
        if (uid == null) return tasks;
        final groups = await _groups.get();
        for (final groupDoc in groups.docs) {

          final memberDoc = await groupDoc.reference
              .collection('members')
              .doc(uid)
              .get();

          if (memberDoc.exists) {
            tasks.addAll(
                await getCompletedTasksForUserInGroup(groupId: groupDoc.id, userId: uid).first
            );
          }
        }

        return tasks;
  }

  Future<List<TaskModel>> getRemainingTasksForUser(
      String? uid,
      ) async {

    final List<TaskModel> tasks = [];
    if (uid == null) return tasks;
    final groups = await _groups.get();
    for (final groupDoc in groups.docs) {

      final memberDoc = await groupDoc.reference
          .collection('members')
          .doc(uid)
          .get();

      if (memberDoc.exists) {
        tasks.addAll(
            await getRemainingTasksForUserInGroup(groupId: groupDoc.id, userId: uid).first
        );
      }
    }

    return tasks;
  }

  Future<void> updateTask({
    required String groupId,
    required String taskId,
    String? title,
    String? objective,
    int? reward,
    bool? isActive,
  }) async {
    final Map<String, dynamic> updates = {};

    if (title != null) updates['title'] = title;
    if (objective != null) updates['objective'] = objective;
    if (reward != null) updates['reward'] = reward;
    if (isActive != null) updates['isActive'] = isActive;

    if (updates.isNotEmpty) {
      await _groups
          .doc(groupId)
          .collection('tasks')
          .doc(taskId)
          .update(updates);
    }
  }

  Future<void> setTaskActive({
    required String groupId,
    required String taskId,
    required bool isActive,
  }) async {
    await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isActive': isActive,
    });
  }

  Future<void> deleteTask({
    required String groupId,
    required String taskId,
  }) async {
    await _groups
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}