import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/task_model.dart';

void main() {
  final now = Timestamp.now();

  group('TaskModel', () {
    test('TM1: constructor stores all fields', () {
      final task = TaskModel(
        id: 't1',
        title: 'Run 5km',
        objective: 'Complete a 5km run',
        reward: 20,
        isActive: true,
        createdAt: now,
      );

      expect(task.id, 't1');
      expect(task.title, 'Run 5km');
      expect(task.objective, 'Complete a 5km run');
      expect(task.reward, 20);
      expect(task.isActive, true);
    });

    test('TM2: default isActive is false', () {
      final task = TaskModel(
          title: 'Run', objective: '', reward: 10, createdAt: now);

      expect(task.isActive, false);
    });

    test('TM3: toFirestore returns correct map', () {
      final task = TaskModel(
        title: 'Run 5km',
        objective: 'Complete a 5km run',
        reward: 20,
        isActive: true,
        createdAt: now,
      );
      final map = task.toFirestore();

      expect(map['title'], 'Run 5km');
      expect(map['objective'], 'Complete a 5km run');
      expect(map['reward'], 20);
      expect(map['isActive'], true);
    });

    test('TM4: fromFirestore reconstructs the model', () {
      final data = {
        'title': 'Run 5km',
        'objective': 'Complete a run',
        'reward': 15,
        'createdAt': now,
        'isActive': true,
      };
      final task = TaskModel.fromFirestore(data, 't1');

      expect(task.id, 't1');
      expect(task.title, 'Run 5km');
      expect(task.reward, 15);
      expect(task.isActive, true);
    });

    test('TM5: fromFirestore handles missing fields with defaults', () {
      final task = TaskModel.fromFirestore({}, 't2');

      expect(task.title, '');
      expect(task.objective, '');
      expect(task.reward, 0);
      expect(task.isActive, false);
    });
  });
}
