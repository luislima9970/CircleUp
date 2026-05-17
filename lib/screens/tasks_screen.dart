import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projesof/screens/createcircle_screen.dart';
import 'package:projesof/screens/task_detail_screen.dart';
import 'package:projesof/screens/profile_screen.dart';

class TasksPageScreen extends StatefulWidget {
  final String userId;
  final FirebaseFirestore? firestore;

  const TasksPageScreen({super.key, required this.userId, this.firestore});

  @override
  State<TasksPageScreen> createState() => _TasksPageScreenState();
}

class _TasksPageScreenState extends State<TasksPageScreen> {
  void _openCirclesPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateCircleScreen()),
    );
  }

  void _openProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }
  Color _themeColor(String theme) {
    if (theme == 'Fitness') return const Color(0xFF2A8CFF);
    if (theme == 'Wellness') return const Color(0xFFFFB84D);
    if (theme == 'Sustainability') return const Color(0xFF43D17A);
    return const Color(0xFF2A8CFF);
  }

  IconData _themeIcon(String theme) {
    if (theme == 'Fitness') return Icons.fitness_center_rounded;
    if (theme == 'Wellness') return Icons.self_improvement_rounded;
    if (theme == 'Sustainability') return Icons.eco_rounded;
    return Icons.groups_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: (widget.firestore ?? FirebaseFirestore.instance).collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingPage();
          }

          final groups = snapshot.data?.docs ?? [];

          return Container(
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
                  ListView(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                    children: [
                      _TasksTopBar(onBack: () => Navigator.pop(context)),

                      const Text(
                        'Tasks separated by group',
                        style: TextStyle(color: Color(0xFF7A8A94)),
                      ),
                      const SizedBox(height: 24),

                      /// Groups
                      for (final group in groups)
                        _GroupTasksCard(
                          group: group,
                          userId: widget.userId,
                          themeColor: _themeColor,
                          themeIcon: _themeIcon,
                          firestore: widget.firestore ?? FirebaseFirestore.instance,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: const Color(0xFF2A8CFF),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          if (index == 1) _openCirclesPage(context);
          if (index == 2) return;
          if (index == 3) {
            _openProfilePage(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
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

class _GroupTasksCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> group;
  final String userId;
  final Color Function(String) themeColor;
  final IconData Function(String) themeIcon;
  final FirebaseFirestore firestore;

  const _GroupTasksCard({
    required this.group,
    required this.userId,
    required this.themeColor,
    required this.themeIcon,
    required this.firestore,
  });

  Color _pastel(Color c) {
    return c.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final groupId = group.id;
    final data = group.data();

    final name = data['name'] ?? '';
    final theme = data['theme'] ?? '';

    final color = themeColor(theme);
    final icon = themeIcon(theme);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .snapshots(),
      builder: (context, memberSnapshot) {
        if (!memberSnapshot.hasData || !memberSnapshot.data!.exists) {
          return const SizedBox();
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collection('groups')
              .doc(groupId)
              .collection('tasks')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, taskSnapshot) {
            final tasks = taskSnapshot.data?.docs ?? [];

            final remainingTasks = tasks.length;

            if (remainingTasks == 0) {
              return const SizedBox();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE5EEF5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _pastel(color),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(26),
                        topRight: Radius.circular(26),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.black),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$remainingTasks tasks remaining',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        for (final task in tasks) ...[
                          _TaskTile(
                            task: task,
                            userId: userId,
                            color: color,
                            groupId: groupId,
                            theme: theme,
                          ),
                          if (task != tasks.last) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> task;
  final String userId;
  final Color color;
  final String groupId;
  final String theme;

  const _TaskTile({
    required this.task,
    required this.userId,
    required this.color,
    required this.groupId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final data = task.data();

    final title = data['title'] ?? '';
    final desc = data['objective'] ?? '';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: task.reference
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String status = 'ACTIVE';
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final submission = snapshot.data!.docs.first.data();
          status = submission['status'] ?? '';
        }

        Color badgeColor;
        String label;

        switch (status) {
          case 'PENDING':
            badgeColor = const Color(0xFFFFE7C2);
            label = 'Pending';
            break;
          case 'APPROVED':
            badgeColor = const Color(0xFFDFF5E3);
            label = 'Done';
            break;
          default:
            badgeColor = const Color(0xFFE4F4EA);
            label = 'Active';
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(
                  groupId: groupId,
                  taskId: task.id,
                  taskTitle: title,
                  taskDescription: desc,
                  themeColor: theme,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(Icons.task_alt, color: color),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1C2A33),
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2A8CFF)),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TasksTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TasksTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1C2A33),
            ),
          ),
        ),

        const SizedBox(width: 16),

        const Expanded(
          child: Text(
            'All Tasks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C2A33),
            ),
          ),
        ),
      ],
    );
  }
}
