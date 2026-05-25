import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projesof/screens/login_screen.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:projesof/widgets/bottom_navbar.dart';

import '../models/group_model.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final GroupService? groupService;
  final TaskService? taskService;

  const ProfileScreen({
    super.key,
    this.groupService,
    this.taskService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final GroupService _groupService;
  late final TaskService _taskService;

  late Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();

    _groupService = widget.groupService ?? GroupService();
    _taskService = widget.taskService ?? TaskService();

    _profileFuture = _loadProfileData();
  }

  Future<_ProfileData> _loadProfileData() async {
    final currentUser = AppState.currentUser;

    if (currentUser == null || currentUser.id == null) {
      return const _ProfileData(
        groups: [],
        completedTasks: 0,
        activeTasks: 0,
      );
    }

    final uid = currentUser.id!;

    final groups = await _groupService.getGroupsForUser(uid).first;
    final completedTasks =
        (await _taskService.getCompletedTasksForUser(uid)).length;
    final activeTasks =
        (await _taskService.getRemainingTasksForUser(uid)).length;

    return _ProfileData(
      groups: groups,
      completedTasks: completedTasks,
      activeTasks: activeTasks,
    );
  }

  String _initial(String username) {
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (updated == true && mounted) {
      setState(() {
        _profileFuture = _loadProfileData();
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    AppState.clearUser();

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
    final user = AppState.currentUser;

    if (user == null || user.id == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFFAF3),
        body: Center(
          child: Text(
            'User not authenticated',
            style: TextStyle(
              color: Color(0xFF1C2A33),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

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

                  final profileData = snapshot.data ??
                      const _ProfileData(
                        groups: [],
                        completedTasks: 0,
                        activeTasks: 0,
                      );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeaderCard(
                          user: user,
                          initial: _initial(user.username),
                          onEdit: _openEditProfile,
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
                                value: profileData.groups.length.toString(),
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

                        _ActivityCard(
                          completedTasks: profileData.completedTasks,
                          activeTasks: profileData.activeTasks,
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
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 3,
      ),
    );
  }
}

class _ProfileData {
  final List<GroupModel> groups;
  final int completedTasks;
  final int activeTasks;

  const _ProfileData({
    required this.groups,
    required this.completedTasks,
    required this.activeTasks,
  });
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final String initial;
  final VoidCallback onEdit;

  const _ProfileHeaderCard({
    required this.user,
    required this.initial,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.trim().isNotEmpty;
    final phrase = user.phrase.trim();

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
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
              child: hasPhoto
                  ? null
                  : Text(
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
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            phrase.isEmpty ? 'No profile phrase yet.' : phrase,
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
              icon: const Icon(
                Icons.edit_rounded,
                size: 18,
              ),
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

class _ActivityCard extends StatelessWidget {
  final int completedTasks;
  final int activeTasks;

  const _ActivityCard({
    required this.completedTasks,
    required this.activeTasks,
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
      child: Row(
        children: [
          Expanded(
            child: _SmallSummaryBox(
              value: completedTasks.toString(),
              label: 'Tasks completed',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SmallSummaryBox(
              value: activeTasks.toString(),
              label: 'Active tasks',
            ),
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