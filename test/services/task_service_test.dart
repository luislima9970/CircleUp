import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/services/task_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TaskService taskService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    taskService = TaskService(firestore: fakeFirestore);
  });

  group('TaskService', () {

    test('TS1: createTask returns a non-empty task id', () async {
      final id = await taskService.createTask(
        groupId: 'g1',
        title: 'Drink water',
        objective: 'Drink 2L',
        reward: 20,
        createdBy: 'uid1',
      );
      expect(id, isNotEmpty);
    });

    test('TS2: createTask sets isActive to true by default', () async {
      final id = await taskService.createTask(
        groupId: 'g1',
        title: 'Drink water',
        objective: 'Drink 2L',
        reward: 20,
        createdBy: 'uid1',
      );

      final doc = await taskService.getTaskById(groupId: 'g1', taskId: id);
      expect(doc.data()?['isActive'], true);
    });

    test('TS3: getTaskById returns correct task data', () async {
      final id = await taskService.createTask(
        groupId: 'g1',
        title: 'Drink water',
        objective: 'Drink 2L',
        reward: 20,
        createdBy: 'uid1',
      );

      final doc = await taskService.getTaskById(groupId: 'g1', taskId: id);
      expect(doc.data()?['title'], 'Drink water');
      expect(doc.data()?['reward'], 20);
      expect(doc.data()?['objective'], 'Drink 2L');
    });

    test('TS4: getActiveTasks returns only active tasks', () async {
      final id1 = await taskService.createTask(
        groupId: 'g1', title: 'Task 1',
        objective: '', reward: 10, createdBy: 'uid1',
      );
      final id2 = await taskService.createTask(
        groupId: 'g1', title: 'Task 2',
        objective: '', reward: 10, createdBy: 'uid1',
      );

      await taskService.setTaskActive(
        groupId: 'g1', taskId: id2, isActive: false,
      );

      final active = await taskService.getActiveTasks('g1');
      expect(active.docs.length, 1);
      expect(active.docs.first.id, id1);
    });

    test('TS5: updateTask changes title and reward', () async {
      final id = await taskService.createTask(
        groupId: 'g1', title: 'Old title',
        objective: '', reward: 10, createdBy: 'uid1',
      );

      await taskService.updateTask(
        groupId: 'g1', taskId: id,
        title: 'New title', reward: 50,
      );

      final doc = await taskService.getTaskById(groupId: 'g1', taskId: id);
      expect(doc.data()?['title'], 'New title');
      expect(doc.data()?['reward'], 50);
    });

    test('TS6: deleteTask removes the task', () async {
      final id = await taskService.createTask(
        groupId: 'g1', title: 'To delete',
        objective: '', reward: 10, createdBy: 'uid1',
      );

      await taskService.deleteTask(groupId: 'g1', taskId: id);

      final doc = await taskService.getTaskById(groupId: 'g1', taskId: id);
      expect(doc.exists, false);
    });

  });
}