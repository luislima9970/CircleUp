import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createTask({
    required String groupId,
    required String title,
    required String objective,
    required int reward,
    required String createdBy,
  }) async {
    final taskRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc();

    await taskRef.set({
      'title': title,
      'objective': objective,
      'reward': reward,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
      'isActive': true,
    });

    return taskRef.id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTaskById({
    required String groupId,
    required String taskId,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTasksForGroup(
      String groupId,
      ) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActiveTasks(
      String groupId,
      ) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .where('isActive', isEqualTo: true)
        .get();
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
      await _firestore
          .collection('groups')
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
    await _firestore
        .collection('groups')
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
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}