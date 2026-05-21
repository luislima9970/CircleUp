import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projesof/screens/login_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:projesof/widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GroupService _groupService = GroupService();

  final _firestore = FirebaseFirestore.instance;

  final user = AppState.currentUser!;
  late Future<_ProfileData> _profileFuture;


  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  int _parseReward(dynamic reward) {
    if (reward is int) return reward;
    if (reward is num) return reward.toInt();
    if (reward is String) return int.tryParse(reward) ?? 0;
    return 0;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  bool _isToday(String dateKey) {
    final date = DateTime.tryParse(dateKey);

    if (date == null) {
      return false;
    }

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _calculateStreak(Set<String> completedDates) {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (completedDates.contains(_dateKey(currentDate))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<_ProfileData> _loadProfileData() async {

    final groups = await _groupService.getGroupsForUser(user.id).first;

    int totalPoints = 0;
    int completedTasks = 0;
    int dailyCompletedTasks = 0;
    int streak = 0;

    final completedDates = <String>{};

    for (final group in groups) {

      final completionsSnapshot = await _firestore //!!!
          .collection('groups')
          .doc(group.id)
          .collection('taskCompletions')
          .where('userId', isEqualTo: user.id)
          .get();

      completedTasks += completionsSnapshot.docs.length;

      for (final completion in completionsSnapshot.docs) {
        final data = completion.data();

        totalPoints += _parseReward(data['reward']);

        final completedDate = data['completedDate']?.toString();

        if (completedDate != null && completedDate.isNotEmpty) {
          completedDates.add(completedDate);

          if (_isToday(completedDate)) {
            dailyCompletedTasks++;
          }
        }
      }
    }

    streak = _calculateStreak(completedDates);

    //update user???

    return _ProfileData(
      phrase: //phrase == null || phrase.isEmpty ?
           'Turning small actions into daily impact.' //??
          //: phrase
      ,
      groupsCount: groups.length,
      completedTasks: completedTasks,
      dailyCompletedTasks: dailyCompletedTasks,
      dailyTarget: groups.length,
    );
  }

  String _initial(String username) {
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }

  String _handle(String username) {
    final cleanUsername = username
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '');

    if (cleanUsername.isEmpty) {
      return '@circleup';
    }

    return '@$cleanUsername';
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF3),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEAF4FF),
              Color(0xFFF8FCFF),
              Color(0xFFEFFAF3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: -90,
                right: -70,
                child: BackgroundCircle(
                  size: 210,
                  color: Color(0x332A8CFF),
                ),
              ),
              const Positioned(
                bottom: -100,
                left: -80,
                child: BackgroundCircle(
                  size: 230,
                  color: Color(0x3343D17A),
                ),
              ),
              FutureBuilder<_ProfileData>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2A8CFF),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load profile.',
                        style: TextStyle(
                          color: Color(0xFF1C2A33),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  final profile = snapshot.data ?? _ProfileData.empty();

                  final progress = profile.dailyTarget == 0
                      ? 0.0
                      : (profile.dailyCompletedTasks / profile.dailyTarget)
                      .clamp(0.0, 1.0);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeaderCard(
                          username: user.username,
                          handle: _handle(user.username),
                          phrase: profile.phrase,
                          initial: _initial(user.username),
                          onEdit: () {},
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.stars_rounded,
                                value: user.totalPoints.toString(),
                                label: 'Points',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.local_fire_department_rounded,
                                value: user.maxStreak == 1
                                    ? '1 day'
                                    : '${user.maxStreak} days',
                                label: 'Streak',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.groups_rounded,
                                value: profile.groupsCount.toString(),
                                label: 'Groups',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Progress Summary',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1C2A33),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _WeeklyActivityCard(
                          completed: profile.dailyCompletedTasks,
                          target: profile.dailyTarget,
                          progress: progress,
                          completedTasks: profile.completedTasks,
                          groupsCount: profile.groupsCount,
                        ),

                        const SizedBox(height: 18),

                        _LogoutCard(
                          onTap: _logout,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      BottomNavbar(
        currentIndex: 3,
      ),
    );
  }
}

class _ProfileData {
  final String phrase;
  final int groupsCount;
  final int completedTasks;
  final int dailyCompletedTasks;
  final int dailyTarget;

  const _ProfileData({
    required this.phrase,
    required this.groupsCount,
    required this.completedTasks,
    required this.dailyCompletedTasks,
    required this.dailyTarget,
  });

      const _ProfileData.empty()
      :phrase = 'Turning small actions into daily impact.',
        groupsCount = 0,
        completedTasks = 0,
        dailyCompletedTasks = 0,
        dailyTarget = 0;
}

class _ProfileHeaderCard extends StatelessWidget {
  final String username;
  final String handle;
  final String phrase;
  final String initial;
  final VoidCallback onEdit;

  const _ProfileHeaderCard({
    required this.username,
    required this.handle,
    required this.phrase,
    required this.initial,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2A8CFF),
            Color(0xFF43D17A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x242A8CFF),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF2A8CFF),
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            handle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            phrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 16,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF43D17A),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8A94),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  final int completed;
  final int target;
  final double progress;
  final int completedTasks;
  final int groupsCount;

  const _WeeklyActivityCard({
    required this.completed,
    required this.target,
    required this.progress,
    required this.completedTasks,
    required this.groupsCount,
  });

  @override
  Widget build(BuildContext context) {
    final taskWord = target == 1 ? 'task' : 'tasks';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily activity',
            style: TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You completed $completed out of $target $taskWord today!',
            style: const TextStyle(
              color: Color(0xFF7A8A94),
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: const Color(0xFFE8F0EA),
              color: const Color(0xFF43D17A),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _SmallSummaryBox(
                  value: completedTasks.toString(),
                  label: 'Challenges done',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallSummaryBox(
                  value: groupsCount.toString(),
                  label: 'Active groups',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSummaryBox extends StatelessWidget {
  final String value;
  final String label;

  const _SmallSummaryBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7A8A94),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE5EEF5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE05252),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE05252),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Leave your current account',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8A94),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF95A39A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
