import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projesof/services/group_service.dart';

import 'createcircle_screen.dart';
import 'tasks_screen.dart';
import 'homepage_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GroupService _groupService = GroupService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  int _parseReward(dynamic reward) {
    if (reward is int) return reward;
    if (reward is num) return reward.toInt();
    if (reward is String) return int.tryParse(reward) ?? 0;
    return 0;
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

  bool _isThisWeek(String dateKey) {
    final date = DateTime.tryParse(dateKey);

    if (date == null) return false;

    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    final cleanDate = DateTime(date.year, date.month, date.day);

    return cleanDate.isAtSameMomentAs(startOfWeek) ||
        cleanDate.isAfter(startOfWeek);
  }

  Future<_ProfileData> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _ProfileData(
        username: 'User',
        email: '',
        profileImageUrl: '',
        groupsCount: 0,
        completedTasks: 0,
        weeklyCompletedTasks: 0,
        weeklyTarget: 7,
        totalPoints: 0,
        streak: 0,
      );
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final username = userData?['username']?.toString().trim();
    final email = userData?['email']?.toString().trim();

    final profileImageUrl =
        userData?['photoUrl']?.toString().trim() ??
            userData?['profileImage']?.toString().trim() ??
            userData?['profileImageUrl']?.toString().trim() ??
            '';

    final groups = await _groupService.getGroupsForUser(user.uid);

    int totalPoints = 0;
    int completedTasks = 0;
    int weeklyCompletedTasks = 0;
    int activeTasksCount = 0;

    final completedDates = <String>{};

    for (final group in groups) {
      final tasksSnapshot = await _firestore
          .collection('groups')
          .doc(group.id)
          .collection('tasks')
          .where('isActive', isEqualTo: true)
          .get();

      activeTasksCount += tasksSnapshot.docs.length;

      final completionsSnapshot = await _firestore
          .collection('groups')
          .doc(group.id)
          .collection('taskCompletions')
          .where('userId', isEqualTo: user.uid)
          .get();

      completedTasks += completionsSnapshot.docs.length;

      for (final completion in completionsSnapshot.docs) {
        final data = completion.data();

        totalPoints += _parseReward(data['reward']);

        final completedDate = data['completedDate']?.toString();

        if (completedDate != null && completedDate.isNotEmpty) {
          completedDates.add(completedDate);

          if (_isThisWeek(completedDate)) {
            weeklyCompletedTasks++;
          }
        }
      }
    }

    final weeklyTarget = activeTasksCount == 0 ? 7 : activeTasksCount;

    return _ProfileData(
      username: username == null || username.isEmpty ? 'User' : username,
      email: email == null || email.isEmpty ? user.email ?? '' : email,
      profileImageUrl: profileImageUrl,
      groupsCount: groups.length,
      completedTasks: completedTasks,
      weeklyCompletedTasks: weeklyCompletedTasks,
      weeklyTarget: weeklyTarget,
      totalPoints: totalPoints,
      streak: _calculateStreak(completedDates),
    );
  }

  String _getInitial(String username) {
    final trimmed = username.trim();

    if (trimmed.isEmpty) return '?';

    return trimmed[0].toUpperCase();
  }

  void _openCirclesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateCircleScreen(),
      ),
    );
  }

  void _openHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomepageScreen(),
      ),
          (route) => false,
    );
  }

  void _openTasksPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TasksPageScreen(userId: user.uid),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
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
                child: _BackgroundCircle(
                  size: 210,
                  color: Color(0x332A8CFF),
                ),
              ),
              const Positioned(
                bottom: -100,
                left: -80,
                child: _BackgroundCircle(
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

                  final profile = snapshot.data ??
                      const _ProfileData(
                        username: 'User',
                        email: '',
                        profileImageUrl: '',
                        groupsCount: 0,
                        completedTasks: 0,
                        weeklyCompletedTasks: 0,
                        weeklyTarget: 7,
                        totalPoints: 0,
                        streak: 0,
                      );

                  final progress = profile.weeklyTarget == 0
                      ? 0.0
                      : profile.weeklyCompletedTasks / profile.weeklyTarget;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileTopCard(
                          username: profile.username,
                          email: profile.email,
                          initial: _getInitial(profile.username),
                          profileImageUrl: profile.profileImageUrl,
                          streak: profile.streak,
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.stars_rounded,
                                value: profile.totalPoints.toString(),
                                label: 'Points',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.local_fire_department_rounded,
                                value: '${profile.streak} days',
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
                          completed: profile.weeklyCompletedTasks,
                          target: profile.weeklyTarget,
                          progress: progress.clamp(0.0, 1.0),
                          completedTasks: profile.completedTasks,
                          groupsCount: profile.groupsCount,
                        ),

                        const SizedBox(height: 22),

                        _ProfileOptionCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          subtitle: profile.email.isEmpty
                              ? 'No email available'
                              : profile.email,
                        ),

                        const SizedBox(height: 12),

                        _ProfileOptionCard(
                          icon: Icons.logout_rounded,
                          title: 'Sign out',
                          subtitle: 'Leave your current account',
                          onTap: _signOut,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        selectedItemColor: const Color(0xFF2A8CFF),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) {
            _openHomePage(context);
          }

          if (index == 1) {
            _openCirclesPage(context);
          }

          if (index == 2) {
            _openTasksPage(context);
          }

          if (index == 3) {
            return;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProfileData {
  final String username;
  final String email;
  final String profileImageUrl;
  final int groupsCount;
  final int completedTasks;
  final int weeklyCompletedTasks;
  final int weeklyTarget;
  final int totalPoints;
  final int streak;

  const _ProfileData({
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.groupsCount,
    required this.completedTasks,
    required this.weeklyCompletedTasks,
    required this.weeklyTarget,
    required this.totalPoints,
    required this.streak,
  });
}

class _ProfileTopCard extends StatelessWidget {
  final String username;
  final String email;
  final String initial;
  final String profileImageUrl;
  final int streak;

  const _ProfileTopCard({
    required this.username,
    required this.email,
    required this.initial,
    required this.profileImageUrl,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final badgeText = streak >= 7
        ? 'Top Consistency Badge'
        : 'Keep Building Consistency';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
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
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
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
            width: 106,
            height: 106,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl.isEmpty
                  ? null
                  : NetworkImage(profileImageUrl),
              child: profileImageUrl.isEmpty
                  ? Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF2A8CFF),
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              )
                  : null,
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

          const SizedBox(height: 6),

          Text(
            email.isEmpty ? '@circleup' : email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Turning small actions into daily impact.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 16,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
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
      height: 134,
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
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
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
            'Weekly activity',
            style: TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You completed $completed out of $target tasks this week.',
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

class _ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
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
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2A8CFF),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8A94),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}