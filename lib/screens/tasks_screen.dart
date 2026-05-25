import 'package:flutter/material.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/screens/task_detail_screen.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:projesof/widgets/bottom_navbar.dart';

class TasksPageScreen extends StatefulWidget {
  final GroupService? groupService;

  const TasksPageScreen({super.key, this.groupService});

  @override
  State<TasksPageScreen> createState() => _TasksPageScreenState();
}

class _TasksPageScreenState extends State<TasksPageScreen> {
  late final GroupService _groupService;

  @override
  void initState() {
    super.initState();
    _groupService = widget.groupService ?? GroupService();
  }
  final user = AppState.currentUser!;

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
      body: StreamBuilder<List<GroupModel>>(
        stream: _groupService.getGroupsForUser(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingPage();
          }

          final groups = snapshot.data;
          if (groups == null) return _TasksEmptyState(color: const Color(0xFF2A8CFF));

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
                          themeColor: _themeColor,
                          themeIcon: _themeIcon,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar:
      BottomNavbar(
        currentIndex: 2,
      ),
    );
  }
}

class _GroupTasksCard extends StatelessWidget {
  final GroupModel group;
  final Color Function(String) themeColor;
  final IconData Function(String) themeIcon;

  const _GroupTasksCard({
    required this.group,
    required this.themeColor,
    required this.themeIcon,
  });

  Color _pastel(Color c) {
    return c.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();
    final SubmissionService submissionService = SubmissionService();
    final color = themeColor(group.theme);
    final icon = themeIcon(group.theme);
    final user = AppState.currentUser!;

    return StreamBuilder<TaskModel?>(
      stream: taskService.getDailyTask(groupId: group.id!),
      builder: (context, taskSnapshot) {
        final task = taskSnapshot.data;
        if (task == null) return const SizedBox();

        return FutureBuilder<SubmissionModel?>(
          future: submissionService.getSubmissionByUser(
            groupId: group.id!,
            taskId: task.id!,
            userId: user.id!,
          ),
          builder: (context, submissionSnapshot) {
            // Hide the group card if the task is already submitted
            if (submissionSnapshot.connectionState == ConnectionState.done &&
                submissionSnapshot.data != null) {
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
                                group.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Today's task",
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
                    child: _TaskTile(
                      task: task,
                      color: color,
                      groupId: group.id!,
                      theme: group.theme,
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
  final TaskModel task;
  final Color color;
  final String groupId;
  final String theme;

  const _TaskTile({
    required this.task,
    required this.color,
    required this.groupId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final SubmissionService submissionService = SubmissionService();
    final user = AppState.currentUser!;
    return FutureBuilder<SubmissionModel?>(
      future: submissionService.getSubmissionByUser(groupId: groupId, taskId: task.id!, userId: user.id!),
      builder: (context, snapshot) {
        String status = 'ACTIVE';
        final submission = snapshot.data;
        if (submission != null) {
          status = submission.status;
        }

        Color badgeColor;
        String label;

        switch (status) {
          case 'PENDING':
            badgeColor = const Color(0xFFFFE7C2);
            label = 'Pending';
            break;
          case 'REJECTED':
            badgeColor = const Color(0xFFF77979);
            label = 'Rejected';
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
                  task: task,
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
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1C2A33),
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        task.objective,
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

class _TasksEmptyState extends StatelessWidget {
  final Color color;

  const _TasksEmptyState({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(26),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.checklist_rounded,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join groups or wait for tasks to appear.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7A8A94),
            ),
          ),
        ],
      ),
    );
  }
}
