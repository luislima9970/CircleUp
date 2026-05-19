import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/task_model.dart';

class TaskService {
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