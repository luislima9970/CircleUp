import 'package:flutter/material.dart';
import 'package:projesof/main.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/group_model.dart';
import 'package:projesof/services/task_service.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:projesof/widgets/bottom_navbar.dart';
import 'package:projesof/widgets/loading_card.dart';
import 'group_page.dart';
import 'user_search_screen.dart';

class HomepageScreen extends StatelessWidget {
  final GroupService? groupService;
  final TaskService? taskService;
  final SubmissionService? submissionService;

  const HomepageScreen({super.key, this.groupService, this.taskService, this.submissionService});

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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(),

                    const SizedBox(height: 26),

                    _ProgressCard(groupService: groupService, taskService: taskService, submissionService: submissionService),

                    const SizedBox(height: 30),

                    const _SectionHeader(
                      title: 'Your Groups',
                    ),

                    const SizedBox(height: 14),

                    _UserGroupsList(groupService: groupService),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      BottomNavbar(
        currentIndex: 0,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {

  _HomeHeader();

  final user = AppState.currentUser!;

  void _openUserSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username.isEmpty ? 'Hello' : 'Hello, ${user.username}',
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
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _openUserSearch(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
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
                Icons.search_rounded,
                color: Color(0xFF2A8CFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatefulWidget {
  final GroupService? groupService;
  final TaskService? taskService;
  final SubmissionService? submissionService;

  const _ProgressCard({this.groupService, this.taskService, this.submissionService});

  @override
  State<_ProgressCard> createState() =>
      _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> with RouteAware {
  late final GroupService _groupService;
  late final TaskService _taskService;
  late final SubmissionService _submissionService;
  final user = AppState.currentUser!;

  Future<_ProgressData>? _progressFuture;
  String _lastGroupsKey = '';

  @override
  void initState() {
    super.initState();
    _groupService = widget.groupService ?? GroupService();
    _taskService = widget.taskService ?? TaskService();
    _submissionService = widget.submissionService ?? SubmissionService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Home screen is visible again — force a fresh computation.
    setState(() => _lastGroupsKey = '');
  }

  Future<_ProgressData> _computeProgress(List<GroupModel> groups) async {
    int totalPoints = 0;
    int pendingTasksCount = 0;

    for (final group in groups) {
      // Sum real-time points from each member document.
      final member = await _groupService.getMember(
        groupId: group.id!,
        userId: user.id!,
      );
      totalPoints += member?.points ?? 0;

      // Count groups where today's task hasn't been submitted yet.
      final dailyTask =
          await _taskService.getDailyTask(groupId: group.id!).first;
      if (dailyTask != null) {
        final submission = await _submissionService.getSubmissionByUser(
          groupId: group.id!,
          taskId: dailyTask.id!,
          userId: user.id!,
        );
        if (submission == null) pendingTasksCount++;
      }
    }

    return _ProgressData(
      groups: groups,
      totalPoints: totalPoints,
      pendingTasksCount: pendingTasksCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: _groupService.getGroupsForUser(user.id),
      builder: (context, groupSnapshot) {
        final groups = groupSnapshot.data ?? [];
        final isLoadingGroups =
            groupSnapshot.connectionState == ConnectionState.waiting;

        // Recreate the future only when the group composition changes.
        final groupsKey = groups.map((g) => g.id).join(',');
        if (groupsKey != _lastGroupsKey) {
          _lastGroupsKey = groupsKey;
          _progressFuture = _computeProgress(groups);
        }

        return FutureBuilder<_ProgressData>(
          future: _progressFuture,
          builder: (context, snapshot) {
            final isLoading = isLoadingGroups ||
                snapshot.connectionState == ConnectionState.waiting;
            final data = snapshot.data;
            final totalPoints = data?.totalPoints ?? 0;
            final pendingTasksCount = data?.pendingTasksCount ?? 0;

            String message;
            if (isLoading) {
              message = 'Loading your progress...';
            } else if (groups.isEmpty) {
              message =
                  'Create or join a group to start completing challenges.';
            } else if (totalPoints > 0) {
              message =
                  'You earned $totalPoints point${totalPoints == 1 ? '' : 's'} in total. Keep going!';
            } else if (pendingTasksCount > 0) {
              message =
                  'You have $pendingTasksCount task${pendingTasksCount == 1 ? '' : 's'} waiting for you today.';
            } else {
              message = 'All done for today! Check back tomorrow.';
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A8CFF), Color(0xFF43D17A)],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Your Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xEFFFFFFF),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _ProgressStatBox(
                          value: groups.length.toString(),
                          label: 'Groups',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProgressStatBox(
                          value: pendingTasksCount.toString(),
                          label: 'Tasks',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProgressStatBox(
                          value: totalPoints.toString(),
                          label: 'Points',
                        ),
                      ),
                    ],
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

class _ProgressData {
  final List<GroupModel> groups;
  final int totalPoints;
  final int pendingTasksCount;

  const _ProgressData({
    required this.groups,
    required this.totalPoints,
    required this.pendingTasksCount,
  });
}

class _ProgressStatBox extends StatelessWidget {
  final String value;
  final String label;

  const _ProgressStatBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserGroupsList extends StatefulWidget {
  final GroupService? groupService;

  const _UserGroupsList({this.groupService});

  @override
  State<_UserGroupsList> createState() => _UserGroupsListState();
}

class _UserGroupsListState extends State<_UserGroupsList> {
  late final GroupService _groupService;

  final user = AppState.currentUser!;

  @override
  void initState() {
    super.initState();
    _groupService = widget.groupService ?? GroupService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: _groupService.getGroupsForUser(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCard();
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
              _GroupCard(group: groups[i]),
              if (i != groups.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;

  const _GroupCard({
    required this.group,
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
    final color = _themeColor(group.theme);
    final icon = _themeIcon(group.theme);

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
                groupId: group.id!,
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
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    if (group.theme.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.theme,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description,
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


