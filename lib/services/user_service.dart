import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/user_model.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _users;
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _users =
            (firestore ?? FirebaseFirestore.instance).collection('users');

  Future<void> createUser({
    required UserModel user,
  }) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUserById(String? userId) async {
    if (userId == null) return null;
    final doc = await _users.doc(userId).get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Future<List<UserModel>> searchOtherUsersByPrefix(
      String query,
      String userId
      ) async {

    final snapshot =
    await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query,)
        .where('username', isLessThan: '$query\uf8ff',)
        .where('id', isNotEqualTo: userId)
        .get();

    return snapshot.docs
        .map(
          (doc) => UserModel.fromFirestore(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    await _users.doc(uid).update({
      'username': username,
    });
  }

  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  }) async {
    await _users.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }
}