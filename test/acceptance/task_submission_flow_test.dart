import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/models/vote_model.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/services/user_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GroupService groupService;
  late TaskService taskService;
  late SubmissionService submissionService;
  late UserService userService;

  late String groupId;
  late String taskId;

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

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    submissionService = SubmissionService(firestore: fakeFirestore);
    taskService = TaskService(
      firestore: fakeFirestore,
      submissionService: submissionService,
    );
    groupService = GroupService(
      firestore: fakeFirestore,
      taskService: taskService,
    );
    userService = UserService(firestore: fakeFirestore);

    await userService.createUser(user: alice);
    await userService.createUser(user: bob);

    groupId = await groupService.createGroup(
      group: GroupModel(
        name: 'Eco Circle',
        theme: 'Sustainability',
        description: 'Go green',
        createdAt: Timestamp.now(),
      ),
    );

    await groupService.addMemberToGroup(groupId: groupId, user: alice);
    await groupService.addMemberToGroup(groupId: groupId, user: bob);

    taskId = await taskService.createTask(
      groupId: groupId,
      task: TaskModel(
        title: 'Plant a tree',
        objective: 'Plant at least one tree',
        reward: 50,
        createdAt: Timestamp.now(),
        isActive: true,
      ),
    );
  });

  group('Task Submission Flow', () {
    test('TF1: Submitting a task creates a PENDING submission', () async {
      await submissionService.createSubmission(
        groupId: groupId,
        taskId: taskId,
        submission: SubmissionModel(userId: alice.id!),
      );

      final submission = await submissionService.getSubmissionByUser(
        groupId: groupId,
        taskId: taskId,
        userId: alice.id!,
      );

      expect(submission, isNotNull);
      expect(submission!.status, 'PENDING');
      expect(submission.validVotes, 0);
      expect(submission.invalidVotes, 0);
    });

    test('TF2: A user cannot submit the same task twice', () async {
      await submissionService.createSubmission(
        groupId: groupId,
        taskId: taskId,
        submission: SubmissionModel(userId: alice.id!),
      );

      expect(
        () => submissionService.createSubmission(
          groupId: groupId,
          taskId: taskId,
          submission: SubmissionModel(userId: alice.id!),
        ),
        throwsException,
      );
    });

    test('TF3: Voting VALID on a submission increments validVotes', () async {
      await submissionService.createSubmission(
        groupId: groupId,
        taskId: taskId,
        submission: SubmissionModel(userId: alice.id!),
      );

      await submissionService.incrementVoteCount(
        groupId: groupId,
        taskId: taskId,
        authorId: alice.id!,
        isValid: true,
      );

      final submission = await submissionService.getSubmissionByUser(
        groupId: groupId,
        taskId: taskId,
        userId: alice.id!,
      );

      expect(submission!.validVotes, 1);
      expect(submission.invalidVotes, 0);
    });

    test('TF4: Voting INVALID on a submission increments invalidVotes', () async {
      await submissionService.createSubmission(
        groupId: groupId,
        taskId: taskId,
        submission: SubmissionModel(userId: alice.id!),
      );

      await submissionService.incrementVoteCount(
        groupId: groupId,
        taskId: taskId,
        authorId: alice.id!,
        isValid: false,
      );

      final submission = await submissionService.getSubmissionByUser(
        groupId: groupId,
        taskId: taskId,
        userId: alice.id!,
      );

      expect(submission!.validVotes, 0);
      expect(submission.invalidVotes, 1);
    });

    test('TF5: A vote is stored and retrievable by the voter', () async {
      await submissionService.createSubmission(
        groupId: groupId,
        taskId: taskId,
        submission: SubmissionModel(userId: alice.id!),
      );

      await submissionService.voteSubmission(
        groupId: groupId,
        taskId: taskId,
        authorId: alice.id!,
        voterId: bob.id!,
        vote: VoteModel(voterId: bob.id!, vote: 'VALID'),
      );

      final vote = await submissionService.getVoteByUser(
        groupId: groupId,
        taskId: taskId,
        authorId: alice.id!,
        voterId: bob.id!,
      );

      expect(vote, isNotNull);
      expect(vote!.vote, 'VALID');
      expect(vote.voterId, bob.id!);
    });

    test(
      'TF6: Approving a submission and awarding points increases the member rank',
      () async {
        await submissionService.createSubmission(
          groupId: groupId,
          taskId: taskId,
          submission: SubmissionModel(userId: alice.id!),
        );

        await submissionService.updateSubmissionStatus(
          groupId: groupId,
          taskId: taskId,
          userId: alice.id!,
          status: 'APPROVED',
        );

        await groupService.incrementMemberPoints(
          groupId: groupId,
          uid: alice.id!,
          delta: 50,
        );

        final submission = await submissionService.getSubmissionByUser(
          groupId: groupId,
          taskId: taskId,
          userId: alice.id!,
        );
        expect(submission!.status, 'APPROVED');

        final member = await groupService.getMember(
          groupId: groupId,
          userId: alice.id!,
        );
        expect(member!.points, 50);
      },
    );

    test(
      'TF7: hasUserSubmittedForTask returns false before submission and true after',
      () async {
        final before = await submissionService.hasUserSubmittedForTask(
          groupId: groupId,
          taskId: taskId,
          authorId: alice.id!,
        );
        expect(before, false);

        await submissionService.createSubmission(
          groupId: groupId,
          taskId: taskId,
          submission: SubmissionModel(userId: alice.id!),
        );

        final after = await submissionService.hasUserSubmittedForTask(
          groupId: groupId,
          taskId: taskId,
          authorId: alice.id!,
        );
        expect(after, true);
      },
    );
  });
}
