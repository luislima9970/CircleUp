import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/screens/tasks_screen.dart';
import 'package:projesof/services/group_service.dart';

import 'createcircle_screen.dart';
import 'group_page.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  void _openCirclesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateCircleScreen(),
      ),
    );
  }

  void _openTasksPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TasksPageScreen(userId: user!.uid),
      ),
    );
  }

  void _showProfileMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile page will be available soon.'),
      ),
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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HomeHeader(),

                    const SizedBox(height: 26),

                    const _ProgressPlaceholderCard(),

                    const SizedBox(height: 30),

                    const _SectionHeader(
                      title: 'Your Groups',
                    ),

                    const SizedBox(height: 14),

                    const _UserGroupsList(),

                    const SizedBox(height: 30),

                    const _SectionHeader(
                      title: 'Pending Tasks',
                    ),

                    const SizedBox(height: 14),

                    const _EmptyStateCard(
                      icon: Icons.checklist_rtl,
                      title: 'No pending tasks',
                      subtitle:
                      'Tasks from your groups will appear here once they are connected.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2A8CFF),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) {
            return;
          }

          if (index == 1) {
            _openCirclesPage(context);
          }

          if (index == 2) {
            _openTasksPage(context);
          }

          if (index == 3) {
            _showProfileMessage(context);
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
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatefulWidget {
  const _HomeHeader();

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  late final Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = _getUsername();
  }

  Future<String> _getUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return '';
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (data == null) {
        return '';
      }

      final username = data['username']?.toString().trim();

      if (username == null || username.isEmpty) {
        return '';
      }

      return username;
    } catch (e) {
      debugPrint('Error loading username: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        final username = snapshot.data ?? '';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isEmpty ? 'Hello' : 'Hello, $username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C2A33),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready for today’s challenges?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7A8A94),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF2A8CFF),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressPlaceholderCard extends StatelessWidget {
  const _ProgressPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A8CFF),
            Color(0xFF43D17A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x242A8CFF),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Today’s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Your progress will appear here once you have groups and tasks.',
            style: TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserGroupsList extends StatefulWidget {
  const _UserGroupsList();

  @override
  State<_UserGroupsList> createState() => _UserGroupsListState();
}

class _UserGroupsListState extends State<_UserGroupsList> {
  final GroupService _groupService = GroupService();

  late final Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _loadUserGroups();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _loadUserGroups() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    return _groupService.getGroupsForUser(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }

        if (snapshot.hasError) {
          return const _EmptyStateCard(
            icon: Icons.error_outline_rounded,
            title: 'Could not load groups',
            subtitle: 'There was a problem loading your groups.',
          );
        }

        final groups = snapshot.data ?? [];

        if (groups.isEmpty) {
          return const _EmptyStateCard(
            icon: Icons.groups_outlined,
            title: 'No groups yet',
            subtitle: 'Your groups will appear here after you create or join one.',
          );
        }

        return Column(
          children: [
            for (int i = 0; i < groups.length; i++) ...[
              _GroupCard(groupDoc: groups[i]),
              if (i != groups.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> groupDoc;

  const _GroupCard({
    required this.groupDoc,
  });

  IconData _themeIcon(String theme) {
    if (theme == 'Fitness') {
      return Icons.fitness_center_rounded;
    }

    if (theme == 'Wellness') {
      return Icons.self_improvement_rounded;
    }

    if (theme == 'Sustainability') {
      return Icons.eco_rounded;
    }

    return Icons.groups_rounded;
  }

  Color _themeColor(String theme) {
    if (theme == 'Fitness') {
      return const Color(0xFF2A8CFF);
    }

    if (theme == 'Wellness') {
      return const Color(0xFFFFB84D);
    }

    if (theme == 'Sustainability') {
      return const Color(0xFF43D17A);
    }

    return const Color(0xFF2A8CFF);
  }

  @override
  Widget build(BuildContext context) {
    final data = groupDoc.data();

    final name = data['name']?.toString() ?? 'Unnamed group';
    final theme = data['theme']?.toString() ?? '';
    final description = data['description']?.toString() ?? '';

    final color = _themeColor(theme);
    final icon = _themeIcon(theme);

    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupPageScreen(
                groupId: groupDoc.id,
              ),
            ),
          );
        },
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    if (theme.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        theme,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C2A33),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
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
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2A8CFF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF7A8A94),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
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
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2A8CFF),
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