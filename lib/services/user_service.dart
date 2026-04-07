import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _userIdFromName(String name) {
    return name.trim().toLowerCase().replaceAll(' ', '_');
  }

  Future<int> loadPoints(String name) async {
    final userId = _userIdFromName(name);
    final docRef = _db.collection('users').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      return (doc.data()?['points'] ?? 0) as int;
    }

    await docRef.set({
      'name': name.trim(),
      'points': 0,
    });

    return 0;
  }

  Future<void> addPoints(String name, int amount) async {
    final userId = _userIdFromName(name);

    await _db.collection('users').doc(userId).set({
      'name': name.trim(),
      'points': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }
}