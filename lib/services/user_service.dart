import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/user_model.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _users =
  FirebaseFirestore.instance.collection('users');

  Future<void> createUser({
    required UserModel user,
  }) async {
    final data = user.toFirestore();

    data['usernameLower'] = user.username.trim().toLowerCase();

    await _users.doc(user.id).set(data);
  }

  Future<UserModel?> getUserById(String? userId) async {
    if (userId == null) return null;

    final doc = await _users.doc(userId).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Future<List<UserModel>> searchOtherUsersByPrefix(
      String query,
      String userId,
      ) async {
    final cleanedQuery = query.trim().toLowerCase();

    final snapshot = await _users.get();

    final users = snapshot.docs
        .where((doc) => doc.id != userId)
        .map(
          (doc) => UserModel.fromFirestore(
        doc.data(),
        doc.id,
      ),
    )
        .where((user) {
      if (cleanedQuery.isEmpty) return true;

      return user.username.trim().toLowerCase().startsWith(cleanedQuery);
    })
        .toList();

    users.sort(
          (a, b) => a.username.toLowerCase().compareTo(
        b.username.toLowerCase(),
      ),
    );

    return users;
  }

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    await _users.doc(uid).update({
      'username': username,
      'usernameLower': username.trim().toLowerCase(),
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

  Future<void> fixOldUsersWithoutUsernameLower() async {
    final snapshot = await _users.get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final username = data['username'];

      if (username is String && username.trim().isNotEmpty) {
        await doc.reference.update({
          'usernameLower': username.trim().toLowerCase(),
        });
      }
    }
  }
}