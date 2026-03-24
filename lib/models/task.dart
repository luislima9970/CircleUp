class Task {
  final String id;
  final String title;
  final int points;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.points,
    this.completed = false,
  });
}
