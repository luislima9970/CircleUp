import 'models/user_model.dart';

class AppState {

  static UserModel? _currentUser;

  static UserModel? get currentUser =>
      _currentUser;

  static void setCurrentUser(
      UserModel user,
      ) {
    _currentUser = user;
  }

  static void clearUser() {
    _currentUser = null;
  }
}