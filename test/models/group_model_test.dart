import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/group_model.dart';

void main() {
  final now = Timestamp.now();

  group('GroupModel', () {
    test('GM1: constructor stores all fields', () {
      final group = GroupModel(
        id: 'g1',
        name: 'Runners',
        theme: 'Fitness',
        description: 'Run daily',
        createdAt: now,
        joinCode: 'ABC123',
      );

      expect(group.id, 'g1');
      expect(group.name, 'Runners');
      expect(group.theme, 'Fitness');
      expect(group.description, 'Run daily');
      expect(group.joinCode, 'ABC123');
    });

    test('GM2: generates a 6-char join code when none provided', () {
      final group = GroupModel(
          name: 'Test', theme: 'Fitness', description: '', createdAt: now);

      expect(group.joinCode.length, 6);
    });

    test('GM3: toFirestore returns correct map', () {
      final group = GroupModel(
        name: 'Runners',
        theme: 'Fitness',
        description: 'Run daily',
        createdAt: now,
        joinCode: 'XYZ999',
      );
      final map = group.toFirestore();

      expect(map['name'], 'Runners');
      expect(map['theme'], 'Fitness');
      expect(map['description'], 'Run daily');
      expect(map['joinCode'], 'XYZ999');
    });

    test('GM4: fromFirestore reconstructs the model', () {
      final data = {
        'name': 'Runners',
        'theme': 'Fitness',
        'description': 'Run daily',
        'createdAt': now,
        'joinCode': 'ABC123',
      };
      final group = GroupModel.fromFirestore(data, 'g1');

      expect(group.id, 'g1');
      expect(group.name, 'Runners');
      expect(group.joinCode, 'ABC123');
    });

    test('GM5: fromFirestore handles missing fields with defaults', () {
      final group = GroupModel.fromFirestore({}, 'g2');

      expect(group.name, '');
      expect(group.theme, '');
      expect(group.description, '');
    });
  });
}
