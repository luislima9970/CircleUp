import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/user_service_interface.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final IUserService userService;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  late final IUserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService;
  }

  final List<Task> tasks = [
    Task(id: 't1', title: '🏃 Do exercise for 10 minutes', points: 10),
    Task(id: 't2', title: '📖 Read for 15 minutes', points: 15),
    Task(id: 't3', title: '💧 Drink 2L of water', points: 20),
    Task(id: 't4', title: '🧹 Clean your room', points: 25),
    Task(id: 't5', title: '🎯 Study for 1 hour', points: 30),
  ];

  Future<void> _completeTask(Task task) async {
    if (task.completed) return;

    setState(() {
      task.completed = true;
    });

    await _userService.addPoints(widget.userName, task.points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/Logo.png',
          height: 90,
        ),
        backgroundColor: const Color.fromARGB(255, 147, 184, 253),
      ),
      body: StreamBuilder<int>(
        stream: _userService.watchPoints(widget.userName),
        builder: (context, snapshot) {
          final totalPoints = snapshot.data ?? 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.deepPurple.shade50,
                child: Column(
                  children: [
                    Text(
                      'Welcome, ${widget.userName}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Points',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '$totalPoints pts',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 50, 108, 194),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          task.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.completed ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: Chip(
                          label: Text('+${task.points} pts'),
                          backgroundColor: Colors.deepPurple.shade100,
                        ),
                        onTap: () => _completeTask(task),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}