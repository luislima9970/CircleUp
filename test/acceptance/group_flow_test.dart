import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GroupService groupService;
  late TaskService taskService;
  late UserService userService;

  final alice = UserModel(
    id: 'alice_uid',
    username: 'alice',
    email: 'alice@test.com',
    createdAt: Timestamp.now(),
  );
  final bob = UserModel(
    id: 'bob_uid',
    username: 'bob',
    email: 'bob@test.com',
    createdAt: Timestamp.now(),
  );
  final carol = UserModel(
    id: 'carol_uid',
    username: 'carol',
    email: 'carol@test.com',
    createdAt: Timestamp.now(),
  );

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    taskService = TaskService(firestore: fakeFirestore);
    groupService = GroupService(
      firestore: fakeFirestore,
      taskService: taskService,
    );
    userService = UserService(firestore: fakeFirestore);

    await userService.createUser(user: alice);
    await userService.createUser(user: bob);
    await userService.createUser(user: carol);
  });

  group('Group Membership Flow', () {
    test('GF1: Creating a group with an owner adds the creator as owner member',
        () async {
      final groupId = await groupService.createGroupWithOwner(
        group: GroupModel(
          name: 'Runners',
          theme: 'Fitness',
          description: 'Run daily',
          createdAt: Timestamp.now(),
        ),
        user: alice,
      );

      final member =
          await groupService.getMember(groupId: groupId, userId: alice.id!);

      expect(member, isNotNull);
      expect(member!.username, 'alice');
      expect(member.role, 'owner');
    });

    test('GF2: Joining a group by its code adds the user as a member',
        () async {
      final groupId = await groupService.createGroupWithOwner(
        group: GroupModel(
          name: 'Eco Warriors',
          theme: 'Sustainability',
          description: 'Save the planet',
          joinCode: 'ECO123',
          createdAt: Timestamp.now(),
        ),
        user: alice,
      );

      await groupService.joinGroupByCode(code: 'ECO123', user: bob);

      final member =
          await groupService.getMember(groupId: groupId, userId: bob.id!);

      expect(member, isNotNull);
      expect(member!.username, 'bob');
      expect(member.role, 'member');
    });

    test('GF3: An invalid join code throws an exception', () async {
      expect(
        () => groupService.joinGroupByCode(code: 'NOPE99', user: bob),
        throwsException,
      );
    });

    test('GF4: Removing a member from a group deletes their entry', () async {
      final groupId = await groupService.createGroupWithOwner(
        group: GroupModel(
          name: 'Wellness Club',
          theme: 'Wellness',
          description: 'Feel well',
          createdAt: Timestamp.now(),
        ),
        user: alice,
      );

      await groupService.addMemberToGroup(groupId: groupId, user: bob);
      await groupService.removeMemberFromGroup(groupId: groupId, uid: bob.id!);

      final member =
          await groupService.getMember(groupId: groupId, userId: bob.id!);

      expect(member, isNull);
    });

    test(
      'GF5: After members earn points the leaderboard orders them correctly',
      () async {
        final groupId = await groupService.createGroup(
          group: GroupModel(
            name: 'Competition',
            theme: 'Fitness',
            description: 'Who is fastest?',
            createdAt: Timestamp.now(),
          ),
        );

        await groupService.addMemberToGroup(groupId: groupId, user: alice);
        await groupService.addMemberToGroup(groupId: groupId, user: bob);
        await groupService.addMemberToGroup(groupId: groupId, user: carol);

        await groupService.updateMemberPoints(
            groupId: groupId, uid: alice.id!, points: 30);
        await groupService.updateMemberPoints(
            groupId: groupId, uid: bob.id!, points: 80);
        await groupService.updateMemberPoints(
            groupId: groupId, uid: carol.id!, points: 55);

        final leaderboard = await groupService.getLeaderboard(groupId).first;

        expect(leaderboard[0].username, 'bob');
        expect(leaderboard[0].points, 80);
        expect(leaderboard[1].username, 'carol');
        expect(leaderboard[1].points, 55);
        expect(leaderboard[2].username, 'alice');
        expect(leaderboard[2].points, 30);
      },
    );

    test(
      'GF6: Updating a user profile propagates to their group memberships',
      () async {
        final groupId = await groupService.createGroup(
          group: GroupModel(
            name: 'Friends',
            theme: 'Wellness',
            description: 'Just friends',
            createdAt: Timestamp.now(),
          ),
        );

        await groupService.addMemberToGroup(groupId: groupId, user: alice);

        await userService.updateUsername(
            uid: alice.id!, username: 'alice_updated');
        await groupService.updateMemberInfoInGroups(
          uid: alice.id!,
          username: 'alice_updated',
        );

        final member =
            await groupService.getMember(groupId: groupId, userId: alice.id!);

        expect(member!.username, 'alice_updated');

        final user = await userService.getUserById(alice.id!);
        expect(user!.username, 'alice_updated');
      },
    );

    test(
      'GF7: getTotalPoints sums points across all groups the user belongs to',
      () async {
        final group1 = await groupService.createGroup(
          group: GroupModel(
            name: 'Group A',
            theme: 'Fitness',
            description: '',
            createdAt: Timestamp.now(),
          ),
        );
        final group2 = await groupService.createGroup(
          group: GroupModel(
            name: 'Group B',
            theme: 'Wellness',
            description: '',
            createdAt: Timestamp.now(),
          ),
        );

        await groupService.addMemberToGroup(groupId: group1, user: alice);
        await groupService.addMemberToGroup(groupId: group2, user: alice);

        await groupService.updateMemberPoints(
            groupId: group1, uid: alice.id!, points: 40);
        await groupService.updateMemberPoints(
            groupId: group2, uid: alice.id!, points: 60);

        final total = await groupService.getTotalPoints(uid: alice.id!);

        expect(total, 100);
      },
    );
  });
}
