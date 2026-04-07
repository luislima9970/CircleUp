import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _docId(String userName) {
    return userName.trim().toLowerCase();
  }

  Future<int> loadPoints(String userName) async {
    final doc = await _db.collection('users').doc(_docId(userName)).get();

    if (!doc.exists) return 0;

    final data = doc.data();
    return (data?['points'] as num?)?.toInt() ?? 0;
  }

  Future<void> addPoints(String userName, int amount) async {
    final ref = _db.collection('users').doc(_docId(userName));

    await ref.set({
      'displayName': userName.trim(),
      'points': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  Stream<int> watchPoints(String userName) {
    return _db
        .collection('users')
        .doc(_docId(userName))
        .snapshots()
        .map((doc) => (doc.data()?['points'] as num?)?.toInt() ?? 0);
  }
}