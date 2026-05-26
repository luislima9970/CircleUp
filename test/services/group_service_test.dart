import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/services/group_service.dart';

GroupModel makeGroup({
  String name = 'Eco Warriors',
  String theme = 'Sustainability',
  String description = 'Green tasks',
  String createdBy = 'uid1',
}) =>
    GroupModel(
      name: name,
      theme: theme,
      description: description,
      createdAt: Timestamp.now(),
    );

UserModel makeUser({String id = 'uid1', String username = 'alice'}) =>
    UserModel(
      id: id,
      username: username,
      email: '$username@email.com',
      createdAt: Timestamp.now(),
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GroupService groupService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    groupService = GroupService(firestore: fakeFirestore);
  });

  group('GroupService', () {
    test('GS1: createGroup returns a non-empty group id', () async {
      final id = await groupService.createGroup(group: makeGroup());
      expect(id, isNotEmpty);
    });

    test('GS2: getGroupById returns correct group data', () async {
      final id = await groupService.createGroup(group: makeGroup());

      final group = await groupService.getGroupById(id);
      expect(group, isNotNull);
      expect(group!.name, 'Eco Warriors');
      expect(group.theme, 'Sustainability');
    });

    test('GS3: getGroupById returns null for unknown id', () async {
      final group = await groupService.getGroupById('nonexistent');
      expect(group, isNull);
    });

    test('GS4: deleteGroup removes the group', () async {
      final id = await groupService.createGroup(
          group: makeGroup(name: 'To Delete', theme: 'Fitness'));

      await groupService.deleteGroup(id);

      final group = await groupService.getGroupById(id);
      expect(group, isNull);
    });

    test('GS5: addMemberToGroup adds member with correct default values',
        () async {
      final groupId =
          await groupService.createGroup(group: makeGroup(theme: 'Wellness'));

      await groupService.addMemberToGroup(
        groupId: groupId,
        user: makeUser(id: 'uid2', username: 'bob'),
      );

      final member =
          await groupService.getMember(groupId: groupId, userId: 'uid2');
      expect(member, isNotNull);
      expect(member!.username, 'bob');
      expect(member.points, 0);
      expect(member.role, 'member');
    });

    test('GS6: removeMemberFromGroup removes the member', () async {
      final groupId =
          await groupService.createGroup(group: makeGroup(theme: 'Wellness'));
      await groupService.addMemberToGroup(
          groupId: groupId, user: makeUser(id: 'uid2', username: 'bob'));

      await groupService.removeMemberFromGroup(groupId: groupId, uid: 'uid2');

      final member =
          await groupService.getMember(groupId: groupId, userId: 'uid2');
      expect(member, isNull);
    });

    test('GS7: updateMemberPoints sets points to the given value', () async {
      final groupId =
          await groupService.createGroup(group: makeGroup(theme: 'Wellness'));
      await groupService.addMemberToGroup(
          groupId: groupId, user: makeUser());

      await groupService.updateMemberPoints(
          groupId: groupId, uid: 'uid1', points: 50);

      final member =
          await groupService.getMember(groupId: groupId, userId: 'uid1');
      expect(member!.points, 50);
    });

    test('GS8: incrementMemberPoints accumulates correctly', () async {
      final groupId =
          await groupService.createGroup(group: makeGroup(theme: 'Wellness'));
      await groupService.addMemberToGroup(
          groupId: groupId, user: makeUser());

      await groupService.incrementMemberPoints(
          groupId: groupId, uid: 'uid1', delta: 20);
      await groupService.incrementMemberPoints(
          groupId: groupId, uid: 'uid1', delta: 30);

      final member =
          await groupService.getMember(groupId: groupId, userId: 'uid1');
      expect(member!.points, 50);
    });

    test('GS9: getLeaderboard returns members ordered by points descending',
        () async {
      final groupId =
          await groupService.createGroup(group: makeGroup(theme: 'Wellness'));
      await groupService.addMemberToGroup(
          groupId: groupId, user: makeUser(id: 'uid1', username: 'alice'));
      await groupService.addMemberToGroup(
          groupId: groupId, user: makeUser(id: 'uid2', username: 'bob'));

      await groupService.updateMemberPoints(
          groupId: groupId, uid: 'uid1', points: 30);
      await groupService.updateMemberPoints(
          groupId: groupId, uid: 'uid2', points: 80);

      final leaderboard =
          await groupService.getLeaderboard(groupId).first;
      expect(leaderboard.first.points, 80);
      expect(leaderboard.last.points, 30);
    });

  });

}
