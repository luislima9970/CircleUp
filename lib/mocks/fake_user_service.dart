import 'dart:async';
import 'package:projesof/services/user_service_interface.dart';

class FakeUserService implements IUserService {
  int points = 0;
  final controller = StreamController<int>.broadcast();

  FakeUserService() {
    controller.add(0);
  }

  @override
  Stream<int> watchPoints(String userName) => controller.stream;

  @override
  Future<void> addPoints(String userName, int pts) async {
    points += pts;
    controller.add(points);
  }
}