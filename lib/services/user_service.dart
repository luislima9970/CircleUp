import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'username': username,
    });
  }

  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}