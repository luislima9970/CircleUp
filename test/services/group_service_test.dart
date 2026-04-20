import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/services/group_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GroupService groupService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    groupService = GroupService(firestore: fakeFirestore);
  });

  group('GroupService', () {

    test('GS1: createGroup returns a non-empty group id', () async {
      final id = await groupService.createGroup(
        name: 'Eco Warriors',
        description: 'Green tasks',
        theme: 'Sustainability',
        createdBy: 'uid1',
      );
      expect(id, isNotEmpty);
    });

    test('GS2: getGroupById returns correct group data', () async {
      final id = await groupService.createGroup(
        name: 'Eco Warriors',
        description: 'Green tasks',
        theme: 'Sustainability',
        createdBy: 'uid1',
      );

      final doc = await groupService.getGroupById(id);
      expect(doc.data()?['name'], 'Eco Warriors');
      expect(doc.data()?['createdBy'], 'uid1');
      expect(doc.data()?['theme'], 'Sustainability');
    });

    test('GS3: getGroupById returns non-existent for unknown id', () async {
      final doc = await groupService.getGroupById('nonexistent');
      expect(doc.exists, false);
    });

    test('GS4: deleteGroup removes the group', () async {
      final id = await groupService.createGroup(
        name: 'To Delete',
        description: '',
        theme: 'Fitness',
        createdBy: 'uid1',
      );

      await groupService.deleteGroup(id);

      final doc = await groupService.getGroupById(id);
      expect(doc.exists, false);
    });

    test('GS5: addMemberToGroup adds member with correct default values', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId,
        uid: 'uid2',
        username: 'bob',
      );

      final member = await groupService.getMember(
        groupId: groupId,
        uid: 'uid2',
      );
      expect(member.exists, true);
      expect(member.data()?['username'], 'bob');
      expect(member.data()?['points'], 0);
      expect(member.data()?['streak'], 0);
      expect(member.data()?['role'], 'member');
    });

    test('GS6: removeMemberFromGroup removes the member', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId,
        uid: 'uid2',
        username: 'bob',
      );

      await groupService.removeMemberFromGroup(
        groupId: groupId,
        uid: 'uid2',
      );

      final member = await groupService.getMember(
        groupId: groupId,
        uid: 'uid2',
      );
      expect(member.exists, false);
    });

    test('GS7: updateMemberPoints sets points to the given value', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId,
        uid: 'uid1',
        username: 'alice',
      );

      await groupService.updateMemberPoints(
        groupId: groupId,
        uid: 'uid1',
        points: 50,
      );

      final member = await groupService.getMember(
        groupId: groupId,
        uid: 'uid1',
      );
      expect(member.data()?['points'], 50);
    });

    test('GS8: incrementMemberPoints accumulates correctly', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId,
        uid: 'uid1',
        username: 'alice',
      );

      await groupService.incrementMemberPoints(
        groupId: groupId, uid: 'uid1', delta: 20,
      );
      await groupService.incrementMemberPoints(
        groupId: groupId, uid: 'uid1', delta: 30,
      );

      final member = await groupService.getMember(
        groupId: groupId,
        uid: 'uid1',
      );
      expect(member.data()?['points'], 50);
    });

    test('GS9: getLeaderboard returns members ordered by points descending', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId, uid: 'uid1', username: 'alice',
      );
      await groupService.addMemberToGroup(
        groupId: groupId, uid: 'uid2', username: 'bob',
      );

      await groupService.updateMemberPoints(
        groupId: groupId, uid: 'uid1', points: 30,
      );
      await groupService.updateMemberPoints(
        groupId: groupId, uid: 'uid2', points: 80,
      );

      final leaderboard = await groupService.getLeaderboard(groupId);
      expect(leaderboard.docs.first.data()['points'], 80);
      expect(leaderboard.docs.last.data()['points'], 30);
    });

    test('GS10: updateMemberStreak stores the streak value', () async {
      final groupId = await groupService.createGroup(
        name: 'Test Group',
        description: '',
        theme: 'Wellness',
        createdBy: 'uid1',
      );

      await groupService.addMemberToGroup(
        groupId: groupId, uid: 'uid1', username: 'alice',
      );

      await groupService.updateMemberStreak(
        groupId: groupId, uid: 'uid1', streak: 7,
      );

      final member = await groupService.getMember(
        groupId: groupId, uid: 'uid1',
      );
      expect(member.data()?['streak'], 7);
    });

  });
}