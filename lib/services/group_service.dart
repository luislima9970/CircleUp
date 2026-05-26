import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/member_model.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/services/task_service.dart';


class GroupService {
  final TaskService _taskService;
  final CollectionReference<Map<String, dynamic>> _groups;

  GroupService({FirebaseFirestore? firestore, TaskService? taskService})
      : _groups = (firestore ?? FirebaseFirestore.instance).collection('groups'),
        _taskService = taskService ?? TaskService(firestore: firestore);

  static final Map<String, List<TaskModel>> _tasksByTheme = {
    'sustainability': [
      TaskModel(
        title: 'Reusable Bag at the Store',
        objective: 'Take a photo of your groceries packed in a reusable bag at the shop or on the way home.',
        reward: 10,
      ),
      TaskModel(
        title: 'Litter Pickup',
        objective: 'Take a photo of the litter you collected from a public space, bagged and ready to dispose.',
        reward: 10,
      ),
      TaskModel(
        title: 'Plant or Garden Care',
        objective: 'Take a photo of a plant you watered, repotted, or planted today.',
        reward: 10,
      ),
      TaskModel(
        title: 'Reusable Water Bottle',
        objective: 'Take a photo of your filled reusable bottle in a public setting.',
        reward: 10,
      ),
      TaskModel(
        title: 'Meatless Meal',
        objective: 'Take a photo of a plant-based meal you prepared, plated and visible.',
        reward: 10,
      ),
      TaskModel(
        title: 'Bicycle or Walking Commute',
        objective: 'Take a photo of your bike at your destination, or a selfie at your destination after walking there.',
        reward: 10,
      ),
      TaskModel(
        title: 'Waste Sorting',
        objective: 'Take a photo of correctly sorted waste separated into the right recycling bins.',
        reward: 10,
      ),
    ],

    'wellness': [
      TaskModel(
        title: 'Healthy Breakfast',
        objective: 'Take a photo of a nutritious homemade breakfast on your table before eating.',
        reward: 10,
      ),
      TaskModel(
        title: 'Nature Walk',
        objective: 'Take a photo of yourself or your surroundings during a walk in a park, forest, or beach.',
        reward: 10,
      ),
      TaskModel(
        title: 'Journaling',
        objective: 'Take a photo of an open journal or notebook with handwritten content visible on the page.',
        reward: 10,
      ),
      TaskModel(
        title: 'Herbal Tea or Healthy Drink',
        objective: 'Take a photo of a prepared herbal tea, smoothie, or infused water you made.',
        reward: 10,
      ),
      TaskModel(
        title: 'Early Morning Sunrise',
        objective: 'Take a photo of the sunrise, proving you were up early and outside.',
        reward: 10,
      ),
      TaskModel(
        title: 'Screen-Free Activity',
        objective: 'Take a photo doing an offline activity: reading a physical book, drawing, doing a puzzle, or playing a table game.',
        reward: 10,
      ),
      TaskModel(
        title: 'Healthy Homemade Meal',
        objective: 'Take a photo of a balanced, home-cooked meal plated and ready to eat.',
        reward: 10,
      ),
    ],

    'fitness': [
      TaskModel(
        title: 'Gym Check-in',
        objective: 'Go to the gym and take a photo at the entrance or next to a piece of equipment.',
        reward: 10,
      ),
      TaskModel(
        title: 'Outdoor Run/Cycling',
        objective: 'Take a photo of your running shoes or bike on a road, track, or trail with visible outdoor surroundings.',
        reward: 10,
      ),
      TaskModel(
        title: 'Post-Workout Selfie',
        objective: 'Take a sweaty selfie right after a workout session showing visible effort.',
        reward: 10,
      ),
      TaskModel(
        title: 'Home Workout Setup',
        objective: 'Take a photo of your workout space set up before or after training.',
        reward: 10,
      ),
      TaskModel(
        title: 'Stretch Session',
        objective: 'Take a photo of yourself in a stretch pose, such as a split or hamstring stretch.',
        reward: 10,
      ),
      TaskModel(
        title: 'Sports Activity',
        objective: 'Take a photo playing any sport with the court or field visible.',
        reward: 10,
      ),
      TaskModel(
        title: 'Staircase Challenge',
        objective: 'Take a photo at the top of a staircase after climbing it.',
        reward: 10,
      ),
    ],
  };

  Future<String> createGroup({
    required GroupModel group,
  }) async {
    final docRef = await _groups.add(group.toFirestore());
    return docRef.id;
  }

  Future<String> createGroupWithOwner({
    required GroupModel group,
    required UserModel user,
  }) async {
    final groupRef = await _groups.add(group.toFirestore());

    await groupRef
        .collection('members')
        .doc(user.id)
        .set(MemberModel(
          userId: user.id!,
          username: user.username,
          photoUrl: user.photoUrl,
          role: 'owner',
        ).toFirestore());

    final tasks = _tasksByTheme[group.theme.toLowerCase()] ?? [];
    for (final task in tasks) {
      await _taskService.createTask(groupId: groupRef.id, task: task);
    }

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
    required UserModel user
  }) async {
    final memberRef = _groups
        .doc(groupId)
        .collection('members')
        .doc(user.id);

    final memberSnap = await memberRef.get();

    if (memberSnap.exists) {
      throw Exception('Already joined');
    }
    await memberRef.set(MemberModel(userId: user.id!, username: user.username, photoUrl: user.photoUrl).toFirestore());
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

  Stream<List<MemberModel>> getLeaderboard(
      String groupId,
      ) {
    return _groups
        .doc(groupId)
        .collection('members')
        .orderBy('points', descending: true)
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

  Future<int> getTotalPoints({
    required String uid
  }) async {
    int points = 0;
    final groups = await getGroupsForUser(uid).first;
    for (final group in groups) {
      final member = await getMember(groupId: group.id!, userId: uid);
      points += member!.points;
    }
    return points;
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

  Future<void> updateMemberInfoInGroups({
    required String uid,
    String? username,
    String? photoUrl,
    String? phrase,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phrase != null) data['phrase'] = phrase;
    final groups = await getGroupsForUser(uid).first;
    for (final group in groups) {
      await _groups
          .doc(group.id)
          .collection('members')
          .doc(uid)
          .update(data);
    }
  }

  Stream<List<GroupModel>> getGroupsForUser(
      String? uid,
      ) {

    return _groups.snapshots().asyncMap(
          (groupsSnapshot) async {

        final List<GroupModel> userGroups = [];
        if (uid == null) return userGroups;

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
      },
    );
  }

  Stream<List<GroupModel>> getGroupsForUserWithTasks(
      String? uid,
      ) {

    return _groups.snapshots().asyncMap(
          (groupsSnapshot) async {

        final List<GroupModel> userGroups = [];
        if (uid == null) return userGroups;

        for (final groupDoc in groupsSnapshot.docs) {

          final memberDoc = await groupDoc.reference
              .collection('members')
              .doc(uid)
              .get();

          if (memberDoc.exists && !(await _taskService.getActiveTasks(groupId: groupDoc.id).isEmpty)) {

            userGroups.add(
              GroupModel.fromFirestore(
                groupDoc.data(),
                groupDoc.id,
              ),
            );
          }
        }

        return userGroups;
      },
    );
  }

  Future<String> joinGroupByCode({
    required String code,
    required UserModel user,
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

    await addMemberToGroup(groupId: groupId, user: user);
    return groupId;
  }
}