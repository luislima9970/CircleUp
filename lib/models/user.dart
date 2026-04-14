class User {
  String _username;
  String _email;
  String _password;
  int _totalPoints;

  User({
    required String username,
    required String email,
    required String password,
    int totalPoints = 0,
  }) : _username = username,
       _email = email,
       _password = password,
       _totalPoints = totalPoints;

  // Getters
  String get username => _username;
  String get email => _email;
  String get password => _password;
  int get totalPoints => _totalPoints;

  // Setters
  set username(String value) {
    // if (value.trim().isEmpty) throw ArgumentError('Username cannot be empty');  login and register already consider this error
    _username = value.trim();
  }

  set email(String value) {
    /*final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim()))                           login and register already consider this error
      throw ArgumentError('Invalid email');*/
    _email = value.trim();
  }

  set password(String value) {  
    /*if (value.length < 6)                                            login and register already consider this error
      throw ArgumentError('Password must be at least 6 characters');*/  
    _password = value;
  }

  set totalPoints(int value) {
    if (value < 0) throw ArgumentError('Points cannot be negative');
    _totalPoints = value;
  }
}
