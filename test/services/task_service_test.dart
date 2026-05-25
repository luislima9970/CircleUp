import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/services/task_service.dart';

TaskModel makeTask({
  String title = 'Drink water',
  String objective = 'Drink 2L',
  int reward = 20,
  bool isActive = true,
}) =>
    TaskModel(
      title: title,
      objective: objective,
      reward: reward,
      isActive: isActive,
      createdAt: Timestamp.now(),
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TaskService taskService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    taskService = TaskService(firestore: fakeFirestore);
  });

  group('TaskService', () {
    test('TS1: createTask returns a non-empty task id', () async {
      final id = await taskService.createTask(groupId: 'g1', task: makeTask());
      expect(id, isNotEmpty);
    });

    test('TS2: createTask stores isActive correctly', () async {
      final id = await taskService.createTask(groupId: 'g1', task: makeTask());

      final task = await taskService.getTaskById(groupId: 'g1', uid: id);
      expect(task, isNotNull);
      expect(task!.isActive, true);
    });

    test('TS3: getTaskById returns correct task data', () async {
      final id = await taskService.createTask(groupId: 'g1', task: makeTask());

      final task = await taskService.getTaskById(groupId: 'g1', uid: id);
      expect(task!.title, 'Drink water');
      expect(task.reward, 20);
      expect(task.objective, 'Drink 2L');
    });

    test('TS4: getTaskById returns null for unknown id', () async {
      final task =
          await taskService.getTaskById(groupId: 'g1', uid: 'nonexistent');
      expect(task, isNull);
    });

    test('TS5: getActiveTasks returns only active tasks', () async {
      final id1 = await taskService.createTask(
          groupId: 'g1', task: makeTask(title: 'Task 1'));
      final id2 = await taskService.createTask(
          groupId: 'g1', task: makeTask(title: 'Task 2'));

      await taskService.setTaskActive(
          groupId: 'g1', taskId: id2, isActive: false);

      final active =
          await taskService.getActiveTasks(groupId: 'g1').first;
      expect(active.length, 1);
      expect(active.first.id, id1);
    });

    test('TS6: updateTask changes title and reward', () async {
      final id = await taskService.createTask(
          groupId: 'g1', task: makeTask(title: 'Old title'));

      await taskService.updateTask(
          groupId: 'g1', taskId: id, title: 'New title', reward: 50);

      final task = await taskService.getTaskById(groupId: 'g1', uid: id);
      expect(task!.title, 'New title');
      expect(task.reward, 50);
    });

    test('TS7: deleteTask removes the task', () async {
      final id = await taskService.createTask(
          groupId: 'g1', task: makeTask(title: 'To delete'));

      await taskService.deleteTask(groupId: 'g1', taskId: id);

      final task = await taskService.getTaskById(groupId: 'g1', uid: id);
      expect(task, isNull);
    });

    test('TS8: setTaskActive toggles isActive to false', () async {
      final id = await taskService.createTask(groupId: 'g1', task: makeTask());

      await taskService.setTaskActive(
          groupId: 'g1', taskId: id, isActive: false);

      final task = await taskService.getTaskById(groupId: 'g1', uid: id);
      expect(task!.isActive, false);
    });
  });
}
