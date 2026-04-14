class User {
  String username;
  String email;
  String password;
  int _totalPoints;

  User({
    required this.username,
    required this.email,
    required this.password,
    int totalPoints = 0,
  }) : _totalPoints = totalPoints;

  // Getter
  int get totalPoints => _totalPoints;

  // Setter
  set totalPoints(int value) {
    if (value < 0) throw ArgumentError('Points cannot be negative');
    _totalPoints = value;
  }
}
