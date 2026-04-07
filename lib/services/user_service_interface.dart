abstract class IUserService {
  Stream<int> watchPoints(String userName);
  Future<void> addPoints(String userName, int points);
}