import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final FirebaseFirestore _firestore;

  GroupService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createGroup({
    required String name,
    required String description,
    required String theme,
    required String createdBy,
  }) async {
    final groupRef = _firestore.collection('groups').doc();

    await groupRef.set({
      'name': name,
      'description': description,
      'theme': theme,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
    });

    return groupRef.id;
  }

  Future<String> createGroupWithOwner({
    required String name,
    required String description,
    required String theme,
    required String createdBy,
    required String username,
    String? photoUrl,
  }) async {
    final groupRef = _firestore.collection('groups').doc();

    final batch = _firestore.batch();

    batch.set(groupRef, {
      'name': name,
      'description': description,
      'theme': theme,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
    });

    batch.set(groupRef.collection('members').doc(createdBy), {
      'username': username,
      'photoUrl': photoUrl,
      'points': 0,
      'streak': 0,
      'role': 'owner',
      'joinedAt': Timestamp.now(),
    });

    await batch.commit();

    return groupRef.id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupById(
      String groupId,
      ) async {
    return await _firestore.collection('groups').doc(groupId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllGroups() async {
    return await _firestore.collection('groups').get();
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  Future<void> addMemberToGroup({
    required String groupId,
    required String uid,
    required String username,
    String? photoUrl,
    String role = 'member',
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .set({
      'username': username,
      'photoUrl': photoUrl,
      'points': 0,
      'streak': 0,
      'role': role,
      'joinedAt': Timestamp.now(),
    });
  }

  Future<void> removeMemberFromGroup({
    required String groupId,
    required String uid,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMember({
    required String groupId,
    required String uid,
  }) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getGroupMembers(
      String groupId,
      ) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getLeaderboard(
      String groupId,
      ) async {
    return await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .orderBy('points', descending: true)
        .get();
  }

  Future<void> updateMemberPoints({
    required String groupId,
    required String uid,
    required int points,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .update({
      'points': points,
    });
  }

  Future<void> incrementMemberPoints({
    required String groupId,
    required String uid,
    required int delta,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .update({
      'points': FieldValue.increment(delta),
    });
  }

  Future<void> updateMemberStreak({
    required String groupId,
    required String uid,
    required int streak,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .update({
      'streak': streak,
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getGroupsForUser(
      String uid,
      ) async {
    final groupsSnapshot = await _firestore.collection('groups').get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> userGroups = [];

    for (final groupDoc in groupsSnapshot.docs) {
      final memberDoc = await groupDoc.reference
          .collection('members')
          .doc(uid)
          .get();

      if (memberDoc.exists) {
        userGroups.add(groupDoc);
      }
    }

    return userGroups;
  }
}