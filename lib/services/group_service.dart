import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/member_model.dart';

class GroupService {
  final _groups = FirebaseFirestore.instance.collection('groups');

  Future<String> createGroup({
    required GroupModel group,
  }) async {
    final docRef = await _groups.add(group.toFirestore());
    return docRef.id;
  }

  Future<String> createGroupWithOwner({
    required GroupModel group,
    required String userId,
  }) async {
    final groupRef = await _groups.add(group.toFirestore());

    await groupRef
        .collection('members')
        .doc(userId)
        .set({
      'userId': userId,
      'points': 0,
      'streak': 0,
      'role': 'owner'
    });

    return groupRef.id;
  }

  Future<GroupModel?> getGroupById(String groupId) async {

    final doc = await _groups.doc(groupId).get();

    if (!doc.exists) return null;

    return GroupModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Stream<List<GroupModel>> getAllGroups() {

    return _groups
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return GroupModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _groups.doc(groupId).delete();
  }

  Future<void> addMemberToGroup({
    required String groupId,
    required String userId
  }) async {
    final memberRef = _groups
        .doc(groupId)
        .collection('members')
        .doc(userId);

    final memberSnap = await memberRef.get();

    if (memberSnap.exists) {
      throw Exception('Already joined');
    }
    await memberRef.set(MemberModel(userId: userId).toFirestore());

  }

  Future<void> removeMemberFromGroup({
    required String groupId,
    required String uid,
  }) async {
    await _groups
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .delete();
  }

  Future<MemberModel?> getMember({
    required String groupId,
    required String userId
  }) async {

    final doc = await _groups.doc(groupId).collection('members').doc(userId).get();

    if (!doc.exists) return null;

    return MemberModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }

  Stream<List<MemberModel>> getGroupMembers({
    required String groupId
}) {

    return _groups
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return MemberModel.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  Future<List<MemberModel>> getLeaderboard(
      String groupId,
      ) async {

    final snapshot = await _groups
        .doc(groupId)
        .collection('members')
        .orderBy('points', descending: true)
        .get();

    return snapshot.docs.map((doc) {

      return MemberModel.fromFirestore(
        doc.data(),
        doc.id,
      );

    }).toList();
  }

  Future<void> updateMemberPoints({
    required String groupId,
    required String uid,
    required int points,
  }) async {
    await _groups
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
    await _groups
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
    await _groups
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .update({
      'streak': streak,
    });
  }

  Future<List<GroupModel>> getGroupsForUser(
      String uid,
      ) async {

    final groupsSnapshot = await _groups.get();

    final List<GroupModel> userGroups = [];

    for (final groupDoc in groupsSnapshot.docs) {

      final memberDoc = await groupDoc.reference
          .collection('members')
          .doc(uid)
          .get();

      if (memberDoc.exists) {

        userGroups.add(
          GroupModel.fromFirestore(
            groupDoc.data(),
            groupDoc.id,
          ),
        );
      }
    }

    return userGroups;
  }

  Future<void> joinGroupByCode({
    required String code,
    required String userId,
  }) async {
    final cleanedCode = code.trim().toUpperCase();


    final query = await _groups
        .where('joinCode', isEqualTo: cleanedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid code');
    }

    final groupDoc = query.docs.first;
    final groupId = groupDoc.id;

    addMemberToGroup(groupId: groupId, userId: userId);
  }
}