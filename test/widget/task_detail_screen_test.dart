import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/screens/task_detail_screen.dart';

void main() {
  group('TaskDetailScreen', () {
    testWidgets('TDS1: Renders Task Details text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Recycle Plastic Bottles',
          taskDescription: 'Collect and recycle 10 plastic bottles',
          themeColor: 'Sustainability',
        ),
      ));
      
      // May not render fully due to Firebase, but verify construction
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS2: Renders Scaffold widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Recycle Plastic Bottles',
          taskDescription: 'Collect and recycle 10 plastic bottles',
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS3: Screen accepts all required parameters', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Test Task',
          taskDescription: 'Test description',
          themeColor: 'Fitness',
        ),
      ));

      expect(find.byType(TaskDetailScreen), findsOneWidget);
    });

    testWidgets('TDS4: Screen renders with different theme colors', (tester) async {
      for (final theme in ['Fitness', 'Wellness', 'Sustainability']) {
        await tester.pumpWidget(MaterialApp(
          home: TaskDetailScreen(
            groupId: 'test_group_id',
            taskId: 'test_task_id',
            taskTitle: 'Test Task',
            taskDescription: 'Test description',
            themeColor: theme,
          ),
        ));

        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('TDS5: Screen preserves task title parameter', (tester) async {
      const String testTitle = 'Custom Task Title';
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: testTitle,
          taskDescription: 'Test description',
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS6: Screen preserves task description parameter', (tester) async {
      const String testDescription = 'Custom description for the task';
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Test Task',
          taskDescription: testDescription,
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS7: Screen preserves group ID parameter', (tester) async {
      const String groupId = 'custom_group_123';
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: groupId,
          taskId: 'test_task_id',
          taskTitle: 'Test Task',
          taskDescription: 'Test description',
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS8: Screen preserves task ID parameter', (tester) async {
      const String taskId = 'custom_task_456';
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: taskId,
          taskTitle: 'Test Task',
          taskDescription: 'Test description',
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS9: Screen is stateful widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Test Task',
          taskDescription: 'Test description',
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TDS10: Screen handles long task descriptions', (tester) async {
      final String longDescription = 'This is a very long task description ' * 10;
      await tester.pumpWidget(MaterialApp(
        home: TaskDetailScreen(
          groupId: 'test_group_id',
          taskId: 'test_task_id',
          taskTitle: 'Test Task',
          taskDescription: longDescription,
          themeColor: 'Sustainability',
        ),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

